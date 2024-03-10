Connect-AzAccount

Get-AzWvdScalingPlan | % { $_.Name; $scaledPools = $_.HostPoolReference; $scaledPools | % { "$($_.HostPoolArmPath.Split("/")[-1]): $($_.ScalingPlanEnabled)" } }