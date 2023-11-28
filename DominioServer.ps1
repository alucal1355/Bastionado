function mostrarMenu 
{ 
     param ( 
           [string]$Titulo = 'Selección de opciones' 
     ) 
     Clear-Host 
     Write-Host "================ $Titulo================" 
      
     
     Write-Host "1. Gestión de objetos "
     Write-Host "2. Configuración de contraseñas seguras" 
     Write-Host "3. Salir" 
}

function MenuGestionObjetos 
{ 
     param ( 
           [string]$Titulo = 'Selección de opciones' 
     ) 
     Clear-Host 
     Write-Host "================ $Titulo================" 
      
     
     Write-Host "1. Crear Usuarios con csv"
     Write-Host "2. Crear Grupos con csv"
     Write-Host "3. Crear Unidades Organizativas con csv"
     Write-Host "4. Salir" 
}

function MenuContraseñas
{
     param ( 
           [string]$Titulo = 'Selección de opciones' 
     ) 
     Clear-Host 
     Write-Host "================ $Titulo================" 
      
     
     Write-Host "1. Cambiar la longitud minima de las contraseñas"
     Write-Host "2. Habilitar requisitos de complejidad de las contraseñas"
     Write-Host "3. Maximo de historial de contraseñas usadas para no repetirse"
     Write-Host "4. Intentos maximos para bloquear cuenta de usuario"
     Write-Host "5. Tiempo de bloqueo de cuenta por accesos erroneos" 
     Write-Host "6. Permitir cifrado reversible de contraseñas"
     Write-Host "7. Salir"
}

do 
{ 
     mostrarMenu 
     $input = Read-Host "Elige una opción" 
     switch ($input) 
     { 
             '1' {
                Clear-Host
                MenuGestionObjetos
                $input2 = Read-Host "Elige una opción"
                $rutadominio = Read-Host "Di la ruta de tu dominio (ejemplo: 'dc=tirant, dc=res-es, dc=ciber')"
                switch ($input2)
                {
                         '1' { 
                            Clear-Host  
                             $pathcsv=Read-Host "Introduce el fichero csv de usuarios"
                             $Users = Import-Csv -Path "$pathcsv" -delimiter ","            
                             foreach ($User in $Users)
                             {
                              $Displayname = $User.Name            
                              $UserFirstname = $User.Surname1            
                              $UserLastname = $User.Surname2                       
                              $SAM = $User.account            
                              $UPN = $User.account          
                              $Description = $User.Dni 
                              $grupo = $User.Grupo
                              $Password = $User.Password      
                              $departamento = $User.Departament  
                              New-ADUser -Name $Displayname -DisplayName $Displayname -SamAccountName $SAM -UserPrincipalName $UPN -GivenName $UserFirstname -Surname $UserLastname -Description $Description -AccountPassword (ConvertTo-SecureString "$Password" -AsPlainText -Force) -Enabled $true -ChangePasswordAtLogon $true –PasswordNeverExpires $false -path "OU=$departamento, $rutadominio" 
                              Add-ADGroupMember -Identity $Departamento -Members $SAM
                                 }
                            pause
                             } 
           
                          '2' { 
                            Clear-Host  
                             $path=Read-Host "Introduce el fichero csv de grupos" 
                             $grupos = import-csv -Path "$path" -delimiter :
                             foreach ($grupo in $grupos)
                             {
                             $pathcompleto=$grupo.path+","+"$rutadominio"
                             New-ADGroup -Name:$grupo.Name -Description:$grupo.Description -GroupCategory:$grupo.Category -GroupScope:$grupo.Scope -Path:$pathcompleto
                                }
                            pause
                              } 
                    
                          '3' { 
                            Clear-Host  
                             $path=Read-Host "Introduce el fichero csv de UOs" 
                             $UOs = import-csv -Path "$path" -delimiter :
                             foreach ($UO in $UOs)
                             {
                	            New-ADOrganizationalUnit -Description:$UO.Description -Name:$UO.Name -Path:"$rutadominio" -ProtectedFromAccidentalDeletion:$false
                             }
                            pause
                              } 

                          '4' {
                            'Saliendo del script...'
                             return
                             }

                          default { 
                                'Por favor, Pulse una de las opciones disponibles [1-4]'
                                 }
                }
                return
             }
           
             '2' { 
                Clear-Host  
                MenuContraseñas 
                $input3 = Read-Host "Elige una opción" 
                $dominio = Read-Host "Di tu dominio completo (ejemplo: Vera.ciber)"
                switch ($input3) 
                {
                    '1' {
                    Clear-Host
                    $longitud=Read-Host "longitud minima de las contraseñas?"
                    Set-ADDefaultDomainPasswordPolicy -identity $dominio -MinPasswordLength $longitud
                    Write-Host "Cambio realizado"
                    }

                    '2' {
                    Clear-Host
                    Write-Host "1. Activar requisitos de complejidad"
                    Write-Host "2. Desactivar requisitos de complejidad"
                    $opcion=Read-Host "Elige una opción"
                    switch ($opcion)
                      {
                        '1' {
                        Set-ADDefaultDomainPasswordPolicy -identity $dominio -ComplexityEnabled $True
                        Write-Host "Cambio realizado"
                        }

                         '2' {
                        Set-ADDefaultDomainPasswordPolicy -identity $dominio -ComplexityEnabled $False
                        Write-Host "Cambio realizado"
                        }
                      }
                    }

                    '3' {
                    Clear-Host
                    $historial=Read-Host "De cuanto quieres que sea el maximo del historial de contraseñas?"
                    Set-ADDefaultDomainPasswordPolicy -identity $dominio -PasswordHistoryCount $historial
                    Write-Host "Cambio realizado"
                    }

                    '4' {
                    Clear-Host
                    $intentos=Read-Host "Cuantos intentos maximos de inicio de sesión quieres?"
                    Set-ADDefaultDomainPasswordPolicy -identity $dominio -LockoutThreshold $intentos
                    Write-Host "Cambio realizado"
                    }

                    '5' {
                    Clear-Host
                    $tiempo=Read-Host "Cuanto tiempo quieres que se bloquee la cuenta? (sintaxis ejemplo 30 minutos: 0.0:30:0)"
                    Set-ADDefaultDomainPasswordPolicy -identity $dominio -LockoutDuration $tiempo
                    Write-Host "Cambios realizados"
                    }

                    '6' {
                     Clear-Host
                     Write-Host "1. Permitir el cifrado reversible de contraseñas (no recomendado)"
                     Write-Host "2. No permitir el cifrado reversible de contraseñas"
                     $opcion=Read-Host "Elige una opción"
                     switch ($opcion)
                      {
                        '1' {
                        Set-ADDefaultDomainPasswordPolicy -identity $dominio -ReversibleEncryptionEnabled $True
                        Write-Host "Cambio realizado"
                        }

                         '2' {
                        Set-ADDefaultDomainPasswordPolicy -identity $dominio -ReversibleEncryptionEnabled $False
                        Write-Host "Cambio realizado"
                        }
                      }
                    }

                    '7' { 
                        'Saliendo del script...'
                        return 
                        }    

                    default { 
                      'Por favor, Pulse una de las opciones disponibles [1-7]'
                   }

                }
                pause

           } 
           
             '3' { 
                'Saliendo del script...'
                return 
                }    

            default { 
              'Por favor, Pulse una de las opciones disponibles [1-5]'
           }
     }  
} 
until ($input -eq 's')