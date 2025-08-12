#!/bin/bash

## Script IaC - Criando infraestrutura do servidor

criar_grupos(){
    local grupo_nome=$1

    if getent group "$grupo_nome" > /dev/null 2>&1 ; then
        echo "Grupo "$grupo_nome" já existe"
    else
        groupadd "$grupo_nome"
        echo "Grupo "$grupo_nome" criado com sucesso"
    fi
}

#Criação de grupos 
criar_grupos GRP_ADM
criar_grupos GRP_VEN
criar_grupos GRP_SEC

# Criação de pastas
mkdir -p /publico /adm /ven /sec

#Trabalho com permissões
echo "Ajustando permissões..."

chown root:GRP_ADM /adm
chown root:GRP_VEN /ven
chown root:GRP_SEC /sec

chmod 770 /adm /ven /sec
chmod 777 /publico

read -r -s -p "Digite uma senha padrao para os usuarios: " pass
echo
#lendo arquivo de usuarios.
while read -r user || [ -n "$user" ]; do

    #Verifica se o usuário já existe no sistema
    if getent passwd "$user" > /dev/null ; then
        echo "Usuario "$user" já existe no sistema"
        continue
    fi
    
    useradd "$user" -m -s /bin/bash -p $(openssl passwd $pass)

    if [ $? -eq 0 ] ;then
        echo "Usuario $user criado com sucesso - utilizar senha padrão"
        passwd $user -e > /dev/null

        if [[ "$user" =~ 1$ ]] ; then
            usermod -G GRP_ADM $user
        else
            usermod -G GRP_VEN $user
        fi
    fi

done < /root/list-users
