variable "web-size" {
  default = "Standard_B2als_v2"
}

variable "web-count" {
  default = 0
}

variable "web-accnic" {
  default = false
}

variable "web-os-disk" {
  type = map(string)
  default = {
    caching = "ReadWrite"
    type = "Standard_LRS"
  }
}

variable "web-data-disk-count" {
  type = number
  default = 1
}

variable "web-data-disk-size" {
  type = number
  default = 32
}

variable "web-data-disk" {
  type = map(string)
  default = {
    caching = "ReadWrite"
    type = "Standard_LRS"
  }
}
