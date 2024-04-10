variable "resource_group_location" {
  default     = "North Europe"
  description = "Location of the resource group."
}

variable "number_of_slave_nodes" {
  default     = 2
  description = "Number of slave nodes to create."
}