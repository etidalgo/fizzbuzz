
param ([string]$RepoBaseDir, [switch]$AndBuildExe)

$installerProjectDir = join-path $RepoBaseDir 'Installer\'
$exeOutputDir = join-path $RepoBaseDir 'FizzBuzz/bin/Release/net6.0'

write-verbose 'Installer dir: $installerProjectDir'
write-verbose 'Exe output dir: $exeOutputDir'

if($AndBuildExe){
    write-host 'Building exe ...'
    $exeSolution = join-path $RepoBaseDir 'FizzBuzz.sln'
    write-verbose 'Solution path: $exeSolution'
    dotnet build $exeSolution --configuration Release
} else {
    write-host 'Bypassing build exe ...'
}

pushd $installerProjectDir
write-host 'Building installer ...'
. ISCC.exe ".\fizzbuzzsetup.iss"
popd

write-host 'Done.'
