## Emirhan Doğanlardan (By.Emirhan)

# Varsayılan Port
def_port='8080'

# Renk Kodları
CR=$'\e[1;31m' CG=$'\e[1;32m' CY=$'\e[1;33m' CB=$'\e[1;34m' CC=$'\e[1;36m' CW=$'\e[1;37m' RS=$'\e[1;0m'

architecture=`uname -m`

# Program Çıkış
terminated() {
    printf "\n\n${RS} ${CR}[${CW}!${CR}]${CY} Program Kapatıldı ${CR}[${CW}!${CR}]${RS}\n"
    exit 1
}

trap terminated SIGTERM
trap terminated SIGINT

kill_pid() {
	if [[ `pidof php` ]]; then
		killall php > /dev/null 2>&1
	fi
	if [[ `pidof ngrok` ]]; then
		killall ngrok > /dev/null 2>&1
	fi	
}


# Sunucu Başlığı
logo(){

clear
echo "${CC}
      ${CC}       ____
      ${CC}      / ___| _   _ _ __  _   _  ___ _   _
      ${CC}      \___ \| | | | '_ \| | | |/ __| | | |
      ${CC} _ _ _ ___) | |_| | | | | |_| | (__| |_| |_ _ _
      ${CC}(_|_|_)____/ \__,_|_| |_|\__,_|\___|\__,_(_|_|_)
      ${CC}
      ${CR} [${CW}~${CR}]${CY} Hazırlayan By.Emirhan ${CG}(${CC} Emirhan Doğanlardan ${CG})${RS}"

}

path(){

    printf "\n${RS} ${CR}[${CW}1${CR}]${CY} Geçerli Yolu Kullan ${CR}[${CG} host/htdocs ${CR}]"
    printf "\n${RS} ${CR}[${CW}2${CR}]${CY} Bir Yol Ayarla"
    printf "\n${RS}"
    printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Bir Barındırma Seçeneği Seçin: ${CC}"
    read red_path
    
    if [[ $red_path == 1 || $red_path == 01 ]]; then
        path=$'./htdocs'
    elif [[ $red_path == 2 || $red_path == 02 ]]; then
        printf "\n${RS} ${CC}Dosya Yolunu Girin [Örneğin : /home/Emirhan/htdocs]"
        printf "\n${RS}"
        printf "\n${RS} ${CR}>>${CG} ${CC}"
        read path
    else
        printf "\n${RS} ${CR}[${CW}!${CR}]${CY} Geçersiz Seçim ${CR}[${CW}!${CR}]${RS}\n"
        sleep 2 ; logo ; path
    fi

    if [[ ! -d "$path" ]]; then
	    mkdir -p "$path"
    fi
    
    menu

}

package(){

	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Ortam Kurulumu...${RS}"

    if [[ -d "/data/data/com.termux/files/home" ]]; then
        if [[ `command -v proot` ]]; then
            printf ''
        else
			printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Yükleniyor ${CY}Proot${RS}\n"
            pkg install proot resolv-conf -y
        fi
    fi

    if [[ `command -v curl` && `command -v php` && `command -v wget` && `command -v unzip` ]]; then
        printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Ortam Kurulumu Tamamlandı !${RS}"
    else
        repr=(curl php wget unzip)
        for i in "${repr[@]}"; do
            type -p "$i" &>/dev/null || 
                { 
                    printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Yükleniyor ${CY}${i}${RS}\n"
                    
                    if [[ `command -v apt` ]]; then
                        apt install "$i" -y
                    elif [[ `command -v apt-get` ]]; then
                        apt-get install "$i" -y
                    elif [[ `command -v pkg` ]]; then
                        pkg install "$i" -y
                    elif [[ `command -v dnf` ]]; then
                        sudo dnf -y install "$i"
                    else
                        printf "\n${RS} ${CR}[${CW}!${CR}]${CY} Yabancı Dağıtım ${CR}[${CW}!${CR}]${RS}\n"
                        exit 1
                    fi
                }
        done
    fi

}

localhost() {

    printf "\n${RS} ${CR}[${CW}-${CR}]${CY} Giriş Portu [default:${def_port}]: ${CC}"
    read port
    port="${port:-${def_port}}"
    printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Bağlantı Noktasında PHP Sunucusunu Başlatılıyor ${CY}${port}${RS}\n"
    cd "$path" && php -S 127.0.0.1:"$port" > /dev/null 2>&1 &
    sleep 2
    printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Başarıyla Barındırıldı : ${CY}http://127.0.0.1:$port ${RS}"
    printf "\n\n ${CR}[${CW}-${CR}]${CC} Çıkmak İçin CTRL + C Tuşlarına Basın.${RS}\n"
    while [ true ]; do
        sleep 0.75
    done

}

install_ngrok() {
	
    if [[ -e "ngrok" ]]; then
		printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Ngrok Zaten Yüklü.${RS}"
	else
		printf "\n${RS} ${CR}[${CW}-${CR}]${CC} Ngrok Yükleniyor...${RS}"
		
		if [[ ("$architecture" == *'arm'*) || ("$architecture" == *'Android'*) ]]; then
			ngrok_file='https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm.zip'
		elif [[ "$architecture" == *'aarch64'* ]]; then
			ngrok_file='https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-arm64.zip'
		elif [[ "$architecture" == *'x86_64'* ]]; then
			ngrok_file='https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-amd64.zip'
		else
			ngrok_file='https://bin.equinox.io/c/4VmDzA7iaHb/ngrok-stable-linux-386.zip'
		fi

        wget "$ngrok_file" --no-check-certificate > /dev/null 2>&1
        ngrok_deb=`basename $ngrok_file`
    
    	if [[ -e "$ngrok_deb" ]]; then
		    unzip "$ngrok_deb" > /dev/null 2>&1
		    rm -rf "$ngrok_deb" > /dev/null 2>&1
		    chmod +x ./ngrok > /dev/null 2>&1
        else
            echo -e "\n${RS} ${CR}[${CW}!${CR}]${CY} Hata Oluştu, Ngrok'u Manuel Olarak Kurun.${RS}"
            exit 1
        fi
    fi

}

ngrok() {

    printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Bağlantı Noktasında PHP Sunucusunu Başlatılıyor ${CY}${def_port}${RS}\n"
    cd "$path" && php -S 127.0.0.1:"$def_port" > /dev/null 2>&1 &
    sleep 1
    printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Ngrok Port'ta Başlatılıyor ${CY}${def_port}${RS}"

    if [[ `command -v termux-chroot` ]]; then
        sleep 2 && termux-chroot ./ngrok http 127.0.0.1:"$def_port" > /dev/null 2>&1 &
    else
        sleep 2 && ./ngrok http 127.0.0.1:"$def_port" > /dev/null 2>&1 &
    fi

    sleep 8
    ngrok_url=$(curl -s -N http://127.0.0.1:4040/api/tunnels | grep -o "https://[0-9a-z]*\.ngrok.io")
    printf "\n\n${RS} ${CR}[${CW}-${CR}]${CG} Başarıyla Barındırıldı : ${CY}${ngrok_url}${RS}"
    printf "\n\n ${CR}[${CW}-${CR}]${CC} Çıkmak İçin CTRL + C Tuşlarına Basın.${RS}\n"
    while [ true ]; do
        sleep 0.75
    done

}

menu() {
		
    echo -e "\n${CR} [${CW}01${CR}]${CG} Localhost ${CR}[${CC}Yerel Bağlantı${CR}]"
	echo -e "${CR} [${CW}02${CR}]${CG} Ngrok.io  ${CR}[${CC}Uzak Bağlantı${CR}]"

	printf "\n${RS} ${CR}[${CW}-${CR}]${CG} Bir Seçenek Seçin: ${CB}"
    read MEW
    
    if [[ "$MEW" == 1 || "$MEW" == 01 ]]; then
		localhost
	elif [[ "$MEW" == 2 || "$MEW" == 02 ]]; then
        ngrok
	else
		printf "\n${RS} ${CR}[${CW}!${CR}]${CY} Geçersiz Seçim ${CR}[${CW}!${CR}]${RS}\n"
		sleep 2 ; logo ; path
	fi

}


kill_pid ; package ; install_ngrok ; logo ; path


