#include "zconf.h"

int getConfKey(char *conf, char *module, char *key, char *value)
{
    if(checkConf(conf) == -1)
    {
        return -1;
    }
    char buf[MAX_LINE];
    FILE *fp = fopen(conf, "r");
    char *p;
    int mflag = 0, kflag = 0;

    if(fp == NULL)
    {
        DEBUG_ERROR("Fail to open config file [%s].", conf);
        return -1;
    }
    while(fgets(buf, 100, fp) != NULL)
    {
        buf[strlen(buf) - 1]='\0';
        if(module != NULL)
        {
            if(strchr(buf, '[') == buf && strstr(buf, module) == buf+1 && strchr(buf, ']') == buf+1+strlen(module))
            {
                mflag = 1;
                while(fgets(buf, 100, fp) != NULL)
                {
                    buf[strlen(buf) - 1]='\0';
                    if(strchr(buf, '[') == buf)
                    {
                        DEBUG_PRINT("Can't find key [%s] in the module [%s].", key, module);
                        fclose(fp);
                        return -1;
                    }
                    else if(strstr(buf, key) == buf && strchr(buf, '=') == buf+strlen(key))
                    {
                        p = buf + strlen(key) + 1;
                        while(isspace(p[0]))
                        {
                            p++;
                        }
                        strcpy(value, p);
                        fclose(fp);
                        DEBUG_PRINT("Key [%s] = %s", key, value);
                        return 0;
                    }
                }
                DEBUG_PRINT("Key [%s] Not Found.", key);
                fclose(fp);
                return -1;
            }
        }
        else
        {
            if(strstr(buf, key) == buf && strchr(buf, '=') == buf+strlen(key))
            {
                p = buf + strlen(key) + 1;
                while(isspace(p[0]))
                {
                    p++;
                }
                strcpy(value, p);
                fclose(fp);
                DEBUG_PRINT("Key [%s] = %s", key, value);
                return 0;
            }
        }
    }
    if(mflag == 0)
    {
        DEBUG_PRINT("Can't find module [%s] in config file.", module);
    }
    if(kflag == 0)
    {
        DEBUG_PRINT("Key [%s] Not Found.", key);
    }
    fclose(fp);
    return -1;
}

int checkConf(char *conf)
{
    if(access(conf, F_OK) == 0)
    {
        return 1;
    }
    else
    {
        DEBUG_ERROR("%s is not exist.\n", conf);
        return -1;
    }
}
