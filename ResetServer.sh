clear
function oculta_senha {		### Funcao para nao exibir a senha durante a digitacao

    ASTERISTICO="*"
    ENTER=$(printf '\r')                        # Teclas de Controle
    BACKSPACE1=$(printf '\b')
    BACKSPACE2=$(printf '\177')
    printf "%s" "$1" >&2
    TERM_ATUAL=$(stty --save)                   # Config Atual
    stty -echo -icrnl -icanon min 1 time 0      # Desabilita impressao
    CARACTERE=0

    while true
    do
        TECLAS=$(dd bs=1 count=1 status=noxfer 2> /dev/null) # Teclas Digitadas
        case $TECLAS in

            $ENTER)
                break ;;

            $BACKSPACE1)
                if ((CARACTERE))
                then
                    printf "%s" "$BACKSPACE1" >&2
                    printf "%c" " " >&2
                    printf "%s" "$BACKSPACE1" >&2
                    ((CARACTERE--))
                fi
                ;;

            $BACKSPACE2)
                if ((CARACTERE))
                then
                    printf "%s" "$BACKSPACE2" >&2
                    printf "%c" " " >&2
                    printf "%s" "$BACKSPACE2" >&2
                    ((CARACTERE--))
                fi
                ;;

            *)
                printf "%c" "$ASTERISTICO" >&2
                CARACTERES[CARACTERE]="$TECLAS"
                ((CARACTERE++))
        esac
    done

    stty "$TERM_ATUAL" ; echo "" >&2    # Volta configuracao do TERMINAL

    for ((i = 0 ; i < CARACTERE ; i++))
    do
        SENHA+="${CARACTERES[i]}"
    done

    echo "$SENHA"

    return 0
}


echo -e "     - Usuario p/ Login iBMC:                    \c"; read USER ; export USER
export PWIBMC=$(oculta_senha "     - Entre com a senha atual:			 ")


listaip=$(cat /lista/listaip.txt)


for hostname in ${listaip};

do
sshpass -p ${PWIBMC} ssh -o StrictHostKeyChecking=no -o ConnectTimeout=30 -t -t Administrator@${hostname} "ipmcset -t fru0 -d frucontrol -v 0"<<EOF 
yes
EOF
done




