configuration ConfigureADDSTools
{
    Node localhost
    {
        WindowsFeature RSAT-ADDS
        {
            Name = "RSAT-ADDS"
            Ensure = "Present"
            IncludeAllSubFeature=$true
        }
        WindowsFeature AD-Certificate
        {
            Name = "AD-Certificate"
            Ensure = "Present"
            IncludeAllSubFeature=$true
        }
    }
}
