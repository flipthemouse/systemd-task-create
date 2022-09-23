#!/bin/bash

############################
#   UserINPUT Scriptname   #
############################
echo Put the scriptname without extension:
read SCRIPT
echo Scriptname: $SCRIPT

#############################
# UserINPUT Execution Timer #
#############################
echo "Put the daily execution time:"
echo "Example: 18:00:00"
echo "<Hour>:<Minute:<Second>"
read ExecTime
echo Your script will be daily executed at $ExecTime

############################
#     Global Variables     #
############################
SYS_PATH=/etc/systemd/system
INTERPRETAR=/bin/bash/sh
DESC_SERVICE="This service executes service, ${SCRIPT}.sh"
DESC_TIMER="This timer schedules the service, ${SCRIPT}.service"

############################
#       Create script      #
############################
echo "###############################"
create_script() {
echo "Create Script"

# Creates the script code body

cat > ./$SCRIPT.sh << EOF
#!/bin/bash
# $0 Stands for the initial script name that executes
/usr/bin/logger -p local1.info "Hallo Welt von $0"
EOF

chmod 770 ./$SCRIPT.sh
echo "Script File created"
echo "###############################"
}
############################
#  Create systemd.service  #
############################
create_service() {
echo "Create Script service"

# Creates the service code body

cat > $SYS_PATH/$SCRIPT.service << EOF
#cat > ./$SCRIPT.service << EOF
[Unit]
Description=$DESC_SERVICE
After=network.target

[Service]
ExecStart=$INTERPRETAR $(pwd)/$SCRIPT.sh
Type=oneshot
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

echo "Script service created"
echo "###############################"
}
#############################
#    Create systemd.timer   #
#############################
create_timer() {
echo "Create Script timer"

# Creates the timer code body

cat > $SYS_PATH/$SCRIPT.timer << EOF
#cat > ./$SCRIPT.timer << EOF
[Unit]
Description=$DESC_TIMER

[Timer]
# OnCalendar=$TIMER
OnCalendar=*-*-* $ExecTime
EOF

echo "Script timer created"
echo "###############################"
}
#############################
#          Reloads          #
#############################
reload_service(){
# restart daemon, enable and start service
echo "Reloading daemon and enabling service"

systemctl daemon-reload
systemctl enable $SCRIPT.service # remove the extension
systemctl start $SCRIPT.service

echo "Service Started"
echo "###############################"
}
reload_timer() {
# restart daemon, enable and start timer
echo "Reloading daemon and enabling timer"

systemctl daemon-reload
systemctl enable $SCRIPT.timer # remove the extension
systemctl start $SCRIPT.timer

echo "Timer Started"
echo "###############################"
}
#####################################
####           MAIN              ####
#####################################
create_script;
create_service;
create_timer;
reload_service;
reload_timer;
