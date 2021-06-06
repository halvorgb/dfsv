export $(grep -v '^#' sv.conf | xargs -d '\n')
COUNTER=0
echo "Checking sv.conf for settings"
for CONFIGURABLE in SV_BASE_HOSTNAME SV_RCON SV_LOCATION ADMIN_NAME; do
	if [[ "${!CONFIGURABLE}" = "" ]]
	then
		read -p "Enter $CONFIGURABLE: " $CONFIGURABLE
	fi
done
printf "\nServer Hostname: $SV_BASE_HOSTNAME\nAdmin: $ADMIN_NAME\nRcon Password: $SV_RCON\nServer Location: $SV_LOCATION\n\n"

echo "Generating docker compose file"
curr_port=27960
rm -rf docker-compose.yml
printf 'version: "3"\n' >> docker-compose.yml
printf 'services:' >> docker-compose.yml 2>&1
for sv_type in mixed cpm vq3 fastcaps teamruns freestyle;do
	i=0
	sv_qty="${sv_type}_count"
	while [[ $i -ne "${!sv_qty}" ]]
	do
		i=$(($i+1))
		curr_name="${sv_type}_${i}"
		curr_hostname="${SV_BASE_HOSTNAME} | ${sv_type^} ${i}"
		printf "
  ${curr_name}:
    build: .
    image: dfsv:latest
    container_name: ${curr_name}
    ports:
      - \"${curr_port}:27960/udp\"
      - \"${curr_port}:27960/tcp\"
    volumes:
      - base:/dfsv
    environment:
      - MDD_ENABLED=${MDD_ENABLED}
      - RS_ID=
      - NAME_ID=${curr_name}
      - SV_TYPE=${sv_type}
      - SV_HOSTNAME=${curr_hostname}
      - SV_RCON=${SV_RCON}
      - SV_LOCATION=${SV_LOCATION}
      - ADMIN_NAME=${ADMIN_NAME}
      - ADMIN_MAIL=${ADMIN_MAIL}
      - ADMIN_DISCORD=${ADMIN_DISCORD}
      - ADMIN_IRC=${ADMIN_IRC}
      - SV_MAPBASE=${SV_MAPBASE}
      - SV_HOMEPAGE=${SV_HOMEPAGE}" >> docker-compose.yml 2>&1
	mkdir servers/base/defrag/$curr_name &>/dev/null
	cp cfgs/${sv_type}.cfg servers/base/defrag/$curr_name/main.cfg
	curr_port=$(($curr_port+1))
	done
done
printf "
volumes:
  base:
    driver_opts:
      type: none
      device: $(pwd)/servers/base
      o: bind
" >> docker-compose.yml 2>&1
read -p "Start servers now? (Y/n): " $REPLY
if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Starting servers..."
    docker-compose up --force-recreate -d
    echo "All set! Check your server's connection with /connect $(hostname -I | cut -d' ' -f1) through a defrag client"
fi
