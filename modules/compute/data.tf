# data "azurerm_subnet" "websubid" {
#   name                 = "websubid"
#   virtual_network_name = var.vnet_name
#   resource_group_name  = var.name
# }


#  data "azurerm_network_interface" "web-net-interface" {
#   name = "web-net-interface"
#   resource_group_name = var.name
# }



# data "azurerm_subnet" "appsubid" {
#   name                 = "appsubid"
#   virtual_network_name = var.vnet_name
#   resource_group_name  = var.name
# }



# data "azurerm_network_interface" "app-net-interface" {
#   name = "app-net-interface"
#   resource_group_name = var.name
# }