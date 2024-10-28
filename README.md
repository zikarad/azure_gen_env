## azure_gen_env
Deploy playground environment via Terraform into Azure cloud
### Main features
- (access credentials, IPs are hidden)
- vnet + 2 subnets
- variable "location"
- variable "jh-count"
  - variable jh-platform (arm64/x86_64)
- variable "web-count"
- small "B" VMs accessible from specific IP
    - jumphosts /availability set/
    - optionaly webserver(s) /availability set, proximity group/
    - variable for acc. NIC (default false) - requires min D2 size VM(s)
    - key-vault with application (service principal) access

### Example
terraform apply -var 'web-count=1' -var 'location={long="Switzerland North",short="sn"}'
