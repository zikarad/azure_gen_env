variable "web-size" {
  default = "Standard_B2s"
}

variable "web-count" {
  default = 0
}

variable "web-accnic" {
  default = false
}

variable "web-os-disk-caching" {
  type = string
  default = "ReadWrite"
}

variable "web-os-disk-type" {
  type = string
  default = "Standard_LRS"
}

variable "web-data-disk-count" {
  type = number
  default = 1
}

variable "web-data-disk-size" {
  type = number
  default = 32
}

variable "web-data-disk-type" {
  type = string
  default = "Standard_LRS"
}

variable "web-data-disk-caching" {
  type = string
  default = "ReadWrite"
}
