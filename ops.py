# coding=utf-8
import os, sys

if len(sys.argv) == 1:
    print("""b18:编译18
dp:上传重启生产环境主网
""")
    sys.exit(0)
if sys.argv[1] == "b18":
    os.system("mvn clean package -P18")
elif sys.argv[1] == "dp":
    os.system("""
    mvn clean package -Dmaven.test.skip=true
    ssh root@47.75.112.246 "cd /opt/Service/rockgame;../kill_process_by_keyword.sh rockgame;mkdir -p backup;cp rockgame-0.0.1-SNAPSHOT.jar backup/rockgame-0.0.1-SNAPSHOT.jar`date "+%Y-%m-%d%H:%M:%S"`"
    scp target/rockgame-0.0.1-SNAPSHOT.jar root@47.75.112.246:/opt/Service/rockgame/rockgame-0.0.1-SNAPSHOT.jar
    mvn clean
    ssh root@47.75.112.246 "cd /opt/Service/rockgame;./start.sh"
    """)
elif sys.argv[1] == "dm":
    os.system("""
    mvn clean package -Dmaven.test.skip=true
    ssh root@47.94.172.117 "cd /opt/Service/rockgame;../kill_process_by_keyword.sh rockgame;mkdir -p backup;cp rockgame-0.0.1-SNAPSHOT.jar backup/rockgame-0.0.1-SNAPSHOT.jar`date "+%Y-%m-%d%H:%M:%S"`"
    scp target/rockgame-0.0.1-SNAPSHOT.jar root@47.94.172.117:/opt/Service/rockgame/rockgame-0.0.1-SNAPSHOT.jar
    mvn clean
    ssh root@47.94.172.117 "cd /opt/Service/rockgame;./start.sh"
    """)