Describe "Help fuction" -Tag "Unit" {
    It "Gets a function" {
        Get-Function | Should -Be "This is a get Function"
    }
}
