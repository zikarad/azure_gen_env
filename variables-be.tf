variable "be-size" {
  default = "Standard_B2als_v2"
}

variable "be-count" {
  default = 0
}

variable "be-accnic" {
  default = false
}

variable "be-os-disk" {
  type = map(string)
  default = {
    caching = "ReadWrite"
    type = "Standard_LRS"
  }
}

variable "be-data-disk-count" {
  type = number
  default = 1
}

variable "be-data-disk-size" {
  type = number
  default = 32
}

variable "be-data-disk" {
  type = map(string)
  default = {
    caching = "ReadWrite"
    type = "Standard_LRS"
  }
}
