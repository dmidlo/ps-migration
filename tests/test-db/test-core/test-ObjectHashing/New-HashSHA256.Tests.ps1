Describe "New-HashSHA256" {

    It "Produces correct SHA-256 hash for various inputs" -Tag 'active' -ForEach @(
        @{
            InputString = 'Hello'
            Expected    = '185F8DB32271FE25F561A6FC938B2E264306EC304EDA518007D1764826381969'
        },
        @{
            InputString = 'World'
            Expected    = '78AE647DC5544D227130A0682A51E30BC7777FBB6D8A8F17007463A3ECD1D524'
        },
        @{
            InputString = 'HelloWorld'
            Expected    = '872E4E50CE9990D8B041330C47C9DDD11BEC6B503AE9386A99DA8584E9BB12C4'
        }
    ) {

        # Act
        $result = New-HashSHA256 -InputString $InputString

        # Assert
        $result | Should -Be $Expected
    }
}
