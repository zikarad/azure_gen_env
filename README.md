### azure_gen_env
- (access credentials, IPs are hidden)
- vnet + 2 subnets
- small "B" VMs accessible from specific IP
    - jumphosts /availability set/
    - optionaly webserver(s) /availability set/ [WIP]
    - variable for acc. NIC (default false) - requires min D2 size VM(s)
    - key-vault with application (service principal) access
