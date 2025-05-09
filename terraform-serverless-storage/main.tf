terraform {
    required_providers {
        yandex = {
            source = "yandex-cloud/yandex"
        }
    }
}

provider "yandex" {
    token = var.yc_token
    cloud_id = var.cloud_id
    folder_id = var.folder_id
}

resource "yandex_iam_service_account" "storage_account" {
    name = "file-storage-sa"
}

resource "yandex_resourcemanager_folder_iam_member" "sa_storage_access" {
    folder_id = var.folder_id
    role = "storage.editor"
    member = "serviceAccount:${yandex_iam_service_account.storage_account.id}"
}

resource "yandex_iam_service_account_static_access_key" "storage_key" {
    service_account_id = yandex_iam_service_account.storage_account.id
    description = "Access key for S3 functions"
}

resource "yandex_storage_bucket" "bucket" {
    access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
    secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
    bucket = var.bucket_name
    force_destroy = true
}

resource "yandex_function" "upload" {
    name = "upload-file"
    runtime = "python311"
    entrypoint = "index.handler"
    memory = "128"
    execution_timeout = "30"
    service_account_id = yandex_iam_service_account.storage_account.id
    user_hash = filesha256("${path.module}/functions/upload.zip")

    environment = {
        AWS_ACCESS_KEY_ID = yandex_iam_service_account_static_access_key.storage_key.access_key
        AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.storage_key.secret_key
        BUCKET_NAME = var.bucket_name
    }

    content {
        zip_filename = "${path.module}/functions/upload.zip"
    }
}

resource "yandex_function" "list" {
    name = "list-files"
    runtime = "python311"
    entrypoint = "index.handler"
    memory = "128"
    execution_timeout = "30"
    service_account_id = yandex_iam_service_account.storage_account.id
    user_hash = filesha256("${path.module}/functions/list.zip")

    environment = {
        AWS_ACCESS_KEY_ID = yandex_iam_service_account_static_access_key.storage_key.access_key
        AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.storage_key.secret_key
        BUCKET_NAME = var.bucket_name
    }

    content {
        zip_filename = "${path.module}/functions/list.zip"
    }
}

resource "yandex_function" "delete" {
    name = "delete-file"
    runtime = "python311"
    entrypoint = "index.handler"
    memory = "128"
    execution_timeout = "30"
    service_account_id = yandex_iam_service_account.storage_account.id
    user_hash = filesha256("${path.module}/functions/delete.zip")

    environment = {
        AWS_ACCESS_KEY_ID = yandex_iam_service_account_static_access_key.storage_key.access_key
        AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.storage_key.secret_key
        BUCKET_NAME = var.bucket_name
    }

    content {
        zip_filename = "${path.module}/functions/delete.zip"
    }
}

resource "yandex_function" "download" {
    name = "download-file"
    runtime = "python311"
    entrypoint = "index.handler"
    memory = "128"
    execution_timeout = "30"
    service_account_id = yandex_iam_service_account.storage_account.id
    user_hash = filesha256("${path.module}/functions/download.zip")

    environment = {
        AWS_ACCESS_KEY_ID = yandex_iam_service_account_static_access_key.storage_key.access_key
        AWS_SECRET_ACCESS_KEY = yandex_iam_service_account_static_access_key.storage_key.secret_key
        BUCKET_NAME = var.bucket_name
    }

    content {
        zip_filename = "${path.module}/functions/download.zip"
    }
}

resource "yandex_function_iam_binding" "upload_public" {
    function_id = yandex_function.upload.id
    role = "serverless.functions.invoker"
    members = ["system:allUsers"]
}

resource "yandex_function_iam_binding" "list_public" {
    function_id = yandex_function.list.id
    role = "serverless.functions.invoker"
    members = ["system:allUsers"]
}

resource "yandex_function_iam_binding" "delete_public" {
    function_id = yandex_function.delete.id
    role = "serverless.functions.invoker"
    members = ["system:allUsers"]
}

resource "yandex_function_iam_binding" "download_public" {
    function_id = yandex_function.download.id
    role = "serverless.functions.invoker"
    members = ["system:allUsers"]
}

data "template_file" "html" {
    template = file("${path.module}/index.html.tpl")

    vars = {
        upload_url = "https://functions.yandexcloud.net/${yandex_function.upload.id}"
        list_url = "https://functions.yandexcloud.net/${yandex_function.list.id}"
        delete_url = "https://functions.yandexcloud.net/${yandex_function.delete.id}"
        download_url = "https://functions.yandexcloud.net/${yandex_function.download.id}" # если публичный
    }
}

resource "yandex_storage_bucket" "html-bucket-2" {
    access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
    secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
    bucket = var.bucket_name_2
    force_destroy = true
    acl = "public-read"
    max_size = 1048576

    website {
        index_document = "index.html"
    }
}

resource "yandex_storage_object" "html-page" {
    access_key = yandex_iam_service_account_static_access_key.storage_key.access_key
    secret_key = yandex_iam_service_account_static_access_key.storage_key.secret_key
    bucket = var.bucket_name_2
    key = "index.html"
    content = data.template_file.html.rendered
    content_type = "text/html"
}