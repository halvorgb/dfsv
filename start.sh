#!/usr/bin/env bash
set -euo pipefail
IFS=$'\n\t'

# something like this?
# mount -o acr -o nolock -o actimeo=9999 212.24.100.183:/nfs/bsp /dfsv/nfs/maps

rm -f /dfsv/servers/base/defrag/dfsv/main.cfg

cp cfgs/${SV_TYPE}.cfg /dfsv/servers/base/defrag/dfsv/main.cfg

cat << EOF >> /dfsv/servers/base/defrag/dfsv/main.cfg
  sets .admin-irc "$ADMIN_IRC"
  sets .admin-discord "$ADMIN_DISCORD"
  sets .admin-mail "$ADMIN_MAIL"
  sets .admin-name "$ADMIN_NAME"
  sets .homepage "$SV_HOMEPAGE"
  sets .mapbase "$SV_MAPBASE"
  sets .server-location "$SV_LOCATION"
  seta rconPassword "$SV_RCON"
  seta sv_hostname "$SV_HOSTNAME"
  seta df_sv_script_idleCfg "dfsv/main.cfg"
  seta g_log "dfsv/dfsv.log"
EOF

if [ $MDD_ENABLED -eq 1 ]
then
  export VM_GAME="0"
  cat cfgs/mdd.cfg >> /dfsv/servers/base/defrag/dfsv/main.cfg
else
  export VM_GAME="2"
fi

if [ $SV_PRIVATE -eq 1 ]
then
cat << EOF >> /dfsv/servers/base/defrag/dfsv/main.cfg
  seta g_password "$SV_PASSWORD"
EOF
fi

case $SV_TYPE in

  mixed | vq3 | cpm)
    MAP_CMD="map hgb-retro" # temporarily changed this becausee im getting rate limited hard by worldspawn
    ;;

  fastcaps)
    MAP_CMD="map q3ctf1"
    ;;

  teamruns)
    MAP_CMD="map ojdf-sa"
    ;;

  freestyle)
    MAP_CMD="devmap amt-freestyle6"
    ;;
esac

printf "$MAP_CMD" >> /dfsv/servers/base/defrag/dfsv/main.cfg 2>&1

/dfsv/servers/base/oDFe.ded.x64 +set fs_homepath . +set fs_include ./nfs +set net_enabled 1 +set net_port $SV_PORT +set com_hunkmegs ${COM_HUNKMEGS} +set sv_pure 0 +set sv_levelTimeReset 1 +set fs_game defrag +set dedicated 2 +set vm_game $VM_GAME +set ttycon_ansicolor 1 +set bot_enable 0 +exec dfsv/main.cfg
