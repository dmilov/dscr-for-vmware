<#
Copyright (c) 2018-2021 VMware, Inc.  All rights reserved

The BSD-2 license (the "License") set forth below applies to all parts of the Desired State Configuration Resources for VMware project.  You may not use this file except in compliance with the License.

BSD-2 License

Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:

Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.

Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the documentation and/or other materials provided with the distribution.

THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
#>

[DscResource()]
class VMHostSharedSwapSpace : EsxCliBaseDSC {
    VMHostSharedSwapSpace() {
        $this.EsxCliCommand = 'sched.swap.system'
    }

    <#
    .DESCRIPTION

    Specifies if the Datastore option should be enabled or not.
    #>
    [DscProperty()]
    [nullable[bool]] $DatastoreEnabled

    <#
    .DESCRIPTION

    Specifies the name of the Datastore used by the Datastore option.
    #>
    [DscProperty()]
    [string] $DatastoreName

    <#
    .DESCRIPTION

    Specifies the order of the Datastore option in the preference of the options of the system-wide shared swap space.
    #>
    [DscProperty()]
    [nullable[long]] $DatastoreOrder

    <#
    .DESCRIPTION

    Specifies if the host cache option should be enabled or not.
    #>
    [DscProperty()]
    [nullable[bool]] $HostCacheEnabled

    <#
    .DESCRIPTION

    Specifies the order of the host cache option in the preference of the options of the system-wide shared swap space.
    #>
    [DscProperty()]
    [nullable[long]] $HostCacheOrder

    <#
    .DESCRIPTION

    Specifies if the host local swap option should be enabled or not.
    #>
    [DscProperty()]
    [nullable[bool]] $HostLocalSwapEnabled

    <#
    .DESCRIPTION

    Specifies the order of the host local swap option in the preference of the options of the system-wide shared swap space.
    #>
    [DscProperty()]
    [nullable[long]] $HostLocalSwapOrder

    [void] Set() {
        try {
            $this.WriteLogUtil('Verbose', $this.SetMethodStartMessage, ($this.DscResourceName))

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $modifyVMHostSharedSwapSpaceMethodArguments = @{}
            if ($null -ne $this.DatastoreName) { $modifyVMHostSharedSwapSpaceMethodArguments.datastorename = $this.DatastoreName }

            $this.ExecuteEsxCliModifyMethod($this.EsxCliSetMethodName, $modifyVMHostSharedSwapSpaceMethodArguments)
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.SetMethodEndMessage, ($this.DscResourceName))
        }
    }

    [bool] Test() {
        try {
            $this.WriteLogUtil('Verbose', $this.TestMethodStartMessage, ($this.DscResourceName))

            $this.ConnectVIServer()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)
            $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

            $result = !$this.ShouldModifySystemWideSharedSwapSpaceConfiguration($esxCliGetMethodResult)

            $this.WriteDscResourceState($result)

            return $result
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.TestMethodEndMessage, ($this.DscResourceName))
        }
    }

    [VMHostSharedSwapSpace] Get() {
        try {
            $this.WriteLogUtil('Verbose', $this.GetMethodStartMessage, ($this.DscResourceName))

            $this.ConnectVIServer()

            $result = [VMHostSharedSwapSpace]::new()

            $vmHost = $this.GetVMHost()
            $this.GetEsxCli($vmHost)

            $this.PopulateResult($result, $vmHost)

            return $result
        }
        finally {
            $this.DisconnectVIServer()

            $this.WriteLogUtil('Verbose', $this.GetMethodEndMessage, ($this.DscResourceName))
        }
    }

    <#
    .DESCRIPTION

    Checks if the system-wide shared swap space configuration should be modified.
    #>
    [bool] ShouldModifySystemWideSharedSwapSpaceConfiguration($esxCliGetMethodResult) {
        $shouldModifySystemWideSharedSwapSpaceConfiguration = @(
            $this.ShouldUpdateDscResourceSetting('DatastoreEnabled', [System.Convert]::ToBoolean($esxCliGetMethodResult.DatastoreEnabled), $this.DatastoreEnabled),
            $this.ShouldUpdateDscResourceSetting('DatastoreName', [string] $esxCliGetMethodResult.DatastoreName, $this.DatastoreName),
            $this.ShouldUpdateDscResourceSetting('DatastoreOrder', [long] $esxCliGetMethodResult.DatastoreOrder, $this.DatastoreOrder),
            $this.ShouldUpdateDscResourceSetting('HostCacheEnabled', [System.Convert]::ToBoolean($esxCliGetMethodResult.HostcacheEnabled), $this.HostCacheEnabled),
            $this.ShouldUpdateDscResourceSetting('HostCacheOrder', [long] $esxCliGetMethodResult.HostcacheOrder, $this.HostCacheOrder),
            $this.ShouldUpdateDscResourceSetting('HostLocalSwapOrder', [long] $esxCliGetMethodResult.HostlocalswapOrder, $this.HostLocalSwapOrder),
            $this.ShouldUpdateDscResourceSetting(
                'HostLocalSwapEnabled',
                [System.Convert]::ToBoolean($esxCliGetMethodResult.HostlocalswapEnabled),
                $this.HostLocalSwapEnabled
            )
        )

        return ($shouldModifySystemWideSharedSwapSpaceConfiguration -Contains $true)
    }

    <#
    .DESCRIPTION

    Populates the result returned from the Get method.
    #>
    [void] PopulateResult($result, $vmHost) {
        $result.Server = $this.Connection.Name
        $result.Name = $vmHost.Name

        $esxCliGetMethodResult = $this.ExecuteEsxCliRetrievalMethod($this.EsxCliGetMethodName)

        $result.DatastoreEnabled = [System.Convert]::ToBoolean($esxCliGetMethodResult.DatastoreEnabled)
        $result.DatastoreName = $esxCliGetMethodResult.DatastoreName
        $result.DatastoreOrder = [long] $esxCliGetMethodResult.DatastoreOrder
        $result.HostCacheEnabled = [System.Convert]::ToBoolean($esxCliGetMethodResult.HostcacheEnabled)
        $result.HostCacheOrder = [long] $esxCliGetMethodResult.HostcacheOrder
        $result.HostLocalSwapEnabled = [System.Convert]::ToBoolean($esxCliGetMethodResult.HostlocalswapEnabled)
        $result.HostLocalSwapOrder = [long] $esxCliGetMethodResult.HostlocalswapOrder
    }
}
