
# Describe 'Test-MACAddressString Function Tests' {

#     # Valid MAC address test cases
#     $validMacAddresses = @(
#         @{ Input = '00:1A:2B:3C:4D:5E'; Expected = '00:1A:2B:3C:4D:5E' }, # Colon-separated Hexadecimal
#         @{ Input = '00-1A-2B-3C-4D-5E'; Expected = '00:1A:2B:3C:4D:5E' }, # Dash-separated Hexadecimal
#         @{ Input = '001A.2B3C.4D5E'; Expected = '00:1A:2B:3C:4D:5E' },    # Dot-separated Hexadecimal
#         @{ Input = '001A2B3C4D5E'; Expected = '00:1A:2B:3C:4D:5E' },      # No Separator (Plain Hexadecimal)
#         @{ Input = '00 1A 2B 3C 4D 5E'; Expected = '00:1A:2B:3C:4D:5E' }, # Space-separated Hexadecimal
#         @{ Input = '00:1a:2b:3c:4d:5e'; Expected = '00:1A:2B:3C:4D:5E' } # Lowercase Hexadecimal with colons
#     )

#     # Invalid MAC address test cases
#     $invalidMacAddresses = @(
#         '5E-4D-3C-2B-1A-00', # Reversed Byte Order
#         '00000000 00011010 00101011 00111100 01001101 01011110', # Binary Representation
#         '00:1G:2B:3C:4D:5E', # Invalid Hex Character
#         '00:1A:2B:3C:4D',    # Incomplete MAC Address
#         '00:1A:2B:3C:4D:5E:7F', # Too Many Octets
#         '001A-2B3C-4D5E',    # Mixed Separators
#         '00:1A:2B:3C:4D:5E ', # Trailing Space
#         ' 00:1A:2B:3C:4D:5E', # Leading Space
#         '00:1A:2B:3C:4D:5E\n', # Newline Character
#         '00:1A:2B:3C:4D:5E\t'  # Tab Character
#     )
    
#     Context 'Valid MAC Address Formats' {
#         It 'TC-01: Should correctly validate and format valid MAC addresses' -ForEach $validMacAddresses {
#             param ($Input, $Expected)

#             $result = Test-MACAddressString -MacAddress $Input
#             $result | Should -Be $Expected
#         }
#     }  

#     Context 'Invalid MAC Address Formats' {
#         It 'TC-02: Should throw an error for invalid MAC addresses' -TestCases $invalidMacAddresses {
#             param ($Input)
#             { Test-MACAddressString -MacAddress $Input } | Should -Throw -ErrorId 'InvalidMACAddressFormat'
#         }
#     }

#     Context 'Pipeline Input' {
#         It 'TC-03: Should accept and process MAC addresses from the pipeline' {
#             $inputMacs = '00:1A:2B:3C:4D:5E', '00-1A-2B-3C-4D-5E'
#             $expectedOutput = '00:1A:2B:3C:4D:5E', '00:1A:2B:3C:4D:5E'
#             $result = $inputMacs | Test-MACAddressString
#             $result | Should -Be $expectedOutput
#         }
#     }

#     Context 'Empty or Null Input' {
#         It 'TC-04: Should throw an error when input is null or empty' {
#             { Test-MACAddressString -MacAddress $null } | Should -Throw -ErrorId 'InvalidMACAddressFormat'
#             { Test-MACAddressString -MacAddress '' } | Should -Throw -ErrorId 'InvalidMACAddressFormat'
#         }
#     }

#     Context 'Whitespace Input' {
#         It 'TC-05: Should throw an error when input is only whitespace' {
#             { Test-MACAddressString -MacAddress '     ' } | Should -Throw -ErrorId 'InvalidMACAddressFormat'
#         }
#     }

#     Context 'Non-String Input' {
#         It 'TC-06: Should throw an error when input is not a string' {
#             { Test-MACAddressString -MacAddress 123456789012 } | Should -Throw -ErrorId 'InvalidMACAddressFormat'
#             { Test-MACAddressString -MacAddress @(0x00, 0x1A, 0x2B, 0x3C, 0x4D, 0x5E) } | Should -Throw -ErrorId 'InvalidMACAddressFormat'
#         }
#     }
# }
