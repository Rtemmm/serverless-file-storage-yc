output "upload_function_url" {
    value = "https://functions.yandexcloud.net/${yandex_function.upload.id}"
}

output "list_function_url" {
    value = "https://functions.yandexcloud.net/${yandex_function.list.id}"
}

output "delete_function_url" {
    value = "https://functions.yandexcloud.net/${yandex_function.delete.id}"
}

output "download_function_url" {
    value = "https://functions.yandexcloud.net/${yandex_function.download.id}"
}