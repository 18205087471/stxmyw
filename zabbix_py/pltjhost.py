#!/bin/python3
import xlrd,os,json,requests,sys
#参考zabbix API 4.0版本:https://www.zabbix.com/documentation/4.0/zh/manual/api

class zabbixtools:
    url = 'http://10.0.18.245/zabbix/api_jsonrpc.php'
    head = {'Content-Type':'application/jsonrequest'}
#获取认证id
    def user_login(self):
        data = {
              "jsonrpc": "2.0",
              "method": "user.login",
              "params": {
                        "user": "admin",
                        "password": "zaq1)OKM"
                        },
               "id": 1,
               "auth": None
                  }
        try:
            request_auth = requests.post(self.url,headers=self.head,data=json.dumps(data))
            request_auth_json = request_auth.json()
            auth = request_auth_json['result']
        except Exception as e:
            return '0'
        return auth
#获取监控主机列表
    def get_hosts(self):
        data={
            "jsonrpc": "2.0",
            "method": "host.get",
            "params": {
                "output": ["hostid","host"],"selectInterfaces": ["interfaceid","ip"]},
            "id": 2,
            "auth": self.user_login()
            }
        
        request_host= requests.post(self.url,headers=self.head,data=json.dumps(data))
        request_host_json = request_host.json()
        return request_host_json

#创建主机        
    def create_hosts(self):
        file=sys.argv[2]
        with xlrd.open_workbook(file) as fb:
            sheet=fb.sheet_by_name('create')
            print('表名称:%s,表行数:%s,表列数:%s'% (sheet.name,sheet.nrows,sheet.ncols))
            for i in range(1,sheet.nrows):
                hostname=sheet.row_values(i)[0]
                hostip=sheet.row_values(i)[1]
                groupid=int(sheet.row_values(i)[2])
                templateid=int(sheet.row_values(i)[3])
                ####################################
                data={
                 "jsonrpc": "2.0",
                 "method": "host.create","params": {"host": hostname,"interfaces": [{"type": 1,"main": 1,"useip": 1,"ip": hostip,"dns":"","port":"10050"}],
                 "groups": [{"groupid":groupid }],
                 "templates": [{"templateid": templateid }],
                 "inventory_mode": 0,
                 "inventory": {"macaddress_a": "01234","macaddress_b": "56768"}},
                 "auth": self.user_login(),
                 "id": 1
                 }        
                request_create=requests.post(self.url,headers=self.head,data=json.dumps(data))
                request_create_json=request_create.json()
#删除主机
    def delete_hosts(self):
        file=sys.argv[2]
        with xlrd.open_workbook(file) as fb:
            sheet=fb.sheet_by_name('delete')
            print('表名称:%s,表行数:%s,表列数:%s'% (sheet.name,sheet.nrows,sheet.ncols))
            delhostname=[]
            for i in range(1,sheet.nrows):
                hostname=sheet.row_values(i)[0]
                delhostname.append(hostname)
            print('获取删除主机名称列表:%s'%(delhostname))
            print('----------------------------------------')
            delhostnameid=[]
            for i in delhostname:
                 data={
                       "jsonrpc": "2.0",
                       "method": "host.get",
                       "params": {"output": ["hostid"],"filter": {"host":i}},
                       "auth":self.user_login(),
                       "id": 1
                      }
                 try:
                     request_delete=requests.post(self.url,headers=self.head,data=json.dumps(data))
                     request_delete_json=request_delete.json()
                     request_delete_hostid=str(request_delete_json['result'][0]['hostid'])
                     delhostnameid.append(request_delete_hostid)
                 except Exception as e:
                     print('无法获取主机%s:ID信息,请在web页面确认该主机是否存在.'%(i))
                     continue                  
                 request_delete_hostid=str(request_delete_json['result'][0]['hostid'])
                 delhostnameid.append(request_delete_hostid)

            print('获取删除主机id列表:%s'%(delhostnameid))
            if len(delhostnameid)== 0:
                print('没有获取任何相关主机hostsid信息,请确检查excel文件信息的准确性.')
                return '0'
          
            print('-------------------------------------')
            del_id={
                 "jsonrpc": "2.0",
                 "method": "host.delete",
                 "params": delhostnameid,
                 "auth": self.user_login(),
                 "id": 1
                  }
            request_del=requests.post(self.url,headers=self.head,data=json.dumps(del_id))
            request_del_json=request_del.json()
            print('删除主机id列表:%s'%(request_del_json))
#导入模板
    def zbx_export(self):
        fb=open(sys.argv[2],encoding='utf8').read()
        data_export={
             "jsonrpc": "2.0",
             "method": "configuration.import",
             "params": { 
                     "format": "xml",
                     "rules": {
                             "applications":{"createMissing":True,"deleteMissing":True},
                             "valueMaps":{"createMissing":True,"updateExisting":True},
                             "groups":{"createMissing":True},
                             "graphs":{"createMissing":True},
                             "screens":{"createMissing":True},
                             "templateScreens":{"createMissing":True},
                             "triggers":{"createMissing":True,"updateExisting":True},
                             "templates":{"createMissing":True},
                             "items":{"createMissing":True,
                             "updateExisting":True,"deleteMissing":True}
                                },
             "source":fb},
             "auth": self.user_login(),
             "id": 1
             }
        request_export=requests.post(self.url,headers=self.head,data=json.dumps(data_export))
        request_export_json=request_export.json()
        return request_export_json

def main():
    if len(sys.argv) == 3:
        if (sys.argv[1] == 'delete' or sys.argv[1] == 'create' or sys.argv[1] == 'export') and  os.path.isfile(sys.argv[2]):
            auths = zabbixtools()
            if auths == 0:
                print('获取认证令牌失败..请检查提交数据的准确性')
                return '0'
            #获取认证令牌    
            print('-------------')
            print('获取用户认证令牌auth:%s'% auths.user_login())
            if sys.argv[1] == 'create': 
                #添加监控主机
                print('-------------')
                print('添加主机log:%s'% auths.create_hosts())
            elif sys.argv[1] == 'delete': 
                #删除主机
                print('-------------')
                print('删除主机log:%s'% auths.delete_hosts())
            if sys.argv[1] == 'export': 
                #导入模板
                print('-------------')
                print('导入模板log:%s'% auths.zbx_export())
            else:
                pass
            #获取线上监控主机列表
            print('--------------')
            hostlist=auths.get_hosts()['result']
            for i in hostlist:
                i['ip']=i['interfaces'][0]['ip']
                del i['interfaces']
                print('目前监控主机列表:%s'%(i))
        else:
            print('执行失败.Usage: /bin/python3 %s delete/create/export target_file'%(sys.argv[0]))
    else:        
        print('执行失败.Usage: /bin/python3 %s delete/create/export target_file'%(sys.argv[0]))
        return '0'
    
if __name__ == '__main__':
    main()
