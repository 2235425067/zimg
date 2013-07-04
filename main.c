#include "zcommon.h"
#include "zlog.h"

int main(int argc, char **argv)
{
    //Read config
    char *conf = "conf/config.ini";
    char log_path[512];
    char strport[10];
    char strmport[10];
    char _mip[128];

    if(getConfKey(conf, "zlog", "log-path", log_path) == -1)
    {
        DEBUG_WARNING("Key log-path read failed. Use ./log as default.");
        strcpy(log_path, "./log");
    }
    else
    {
        DEBUG_PRINT("Get log-path: %s", log_path);
    }

    if(isDir(log_path) != 1)
    {
        if(mkDir(log_path) != 1)
        {
            DEBUG_ERROR("log_path[%s] Create Failed!", log_path);
            return -1;
        }
    }

    //start log module... ./log/zimg.log
    log_init();
    char *logFile = (char *)malloc(strlen(log_path) + 10);
    sprintf(logFile, "%s/zimg.log", log_path);
    _log_id = log_open(logFile, "a");
    LOG_PRINT(LOG_INFO, "这是INFO LOG测试，LEVEL=%d.", LOG_INFO);


    LOG_PRINT(LOG_INFO, "Begin to Read Config File[%s]", conf);

    if(getConfKey(conf, "zhttpd", "port", strport) == -1)
    {
        LOG_PRINT(LOG_WARNING, "Key port read failed. Use 4869 as default.");
        strcpy(strport, "4869");
    }
    else
    {
        LOG_PRINT(LOG_INFO, "Get port: %s", strport);
    }
    _port = atoi(strport);

    if(getConfKey(conf, "memcached", "mport", strmport) == -1)
    {
        LOG_PRINT(LOG_WARNING, "Key mport read failed. Use 11211 as default.");
        strcpy(strmport, "11211");
    }
    else
    {
        LOG_PRINT(LOG_INFO, "Get mport: %s", strmport);
    }

    if(getConfKey(conf, "zhttpd", "root-path", _root_path) == -1)
    {
        LOG_PRINT(LOG_WARNING, "Key root-path read failed. Use ./www as default.");
        strcpy(_root_path, "./www");
    }
    else
    {
        LOG_PRINT(LOG_INFO, "Get root_path: %s", _root_path);
    }

    if(getConfKey(conf, "zimg", "img-path", _img_path) == -1)
    {
        LOG_PRINT(LOG_WARNING, "Key img-path read failed. Use ./img as default.");
        strcpy(_img_path, "./img");
    }
    else
    {
        LOG_PRINT(LOG_INFO, "Get img-path: %s", _img_path);
    }

    if(getConfKey(conf, "memcached", "mip", _mip) == -1)
    {
        LOG_PRINT(LOG_WARNING, "Key mip read failed. Use 127.0.0.1 as default.");
        strcpy(_mip, "127.0.0.1");
    }
    else
    {
        LOG_PRINT(LOG_INFO, "Get mip: %s", _mip);
    }


    LOG_PRINT(LOG_INFO, "%s Read Finished.", conf);

    //init the Path zimg need to use.
    LOG_PRINT(LOG_INFO, "Begin to Init the Path zimg Using...");
    if(isDir(_root_path) != 1)
    {
        if(mkDir(_root_path) != 1)
        {
            LOG_PRINT(LOG_ERROR, "_root_path[%s] Create Failed!", _root_path);
            return -1;
        }
    }

    if(isDir(_img_path) != 1)
    {
        if(mkDir(_img_path) != 1)
        {
            LOG_PRINT(LOG_ERROR, "_img_path[%s] Create Failed!", _img_path);
            return -1;
        }
    }
    LOG_PRINT(LOG_INFO,"Paths Init Finished.");
    
    //init memcached connection...
    LOG_PRINT(LOG_INFO, "Begin to Init Memcached Connection...");
    _memc= memcached_create(NULL);

    char *mserver = (char *)malloc(strlen(_mip) + strlen(strmport) + 2);
    sprintf(mserver, "%s:%s", _mip, strmport);
    memcached_server_st *servers = memcached_servers_parse(mserver);

    memcached_server_push(_memc, servers);
    memcached_server_list_free(servers);
    memcached_behavior_set(_memc, MEMCACHED_BEHAVIOR_BINARY_PROTOCOL, 0);
    LOG_PRINT(LOG_INFO, "Memcached Connection Init Finished.");
    LOG_PRINT(LOG_INFO, "memcached connection to: %s", mserver);
    free(mserver);

    //begin to start httpd...
    LOG_PRINT(LOG_INFO, "Begin to Start Httpd Server...");
    if(startHttpd(_port, _root_path) == -1)
    {
        LOG_PRINT(LOG_ERROR, "zhttpd start failed.");
    }

    memcached_free(_memc);
    log_close(_log_id);
    return 0;
}
