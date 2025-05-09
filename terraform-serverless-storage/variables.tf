variable "yc_token" {
    description = "Yandex Cloud IAM token"
    type = string
}

variable "cloud_id" {
    description = "Yandex Cloud cloud_id"
    type = string
}

variable "folder_id" {
    description = "Yandex Cloud folder_id"
    type = string
}

variable "bucket_name" {
    description = "Имя бакета"
    type = string
    default = "files-bucket-123123sfsdsfdf123"
}

variable "bucket_name_2" {
    description = "Имя бакета"
    type = string
    default = "html-bucket-123123dsfsdfrtrrrrdffdds123"
}