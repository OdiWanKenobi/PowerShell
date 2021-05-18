Function Get-Commands

{

 Param($verb,

       $noun)

 Get-Command @PSBoundParameters | Sort-Object module | more

}