import sys, getopt
import json
import os

ru_symbols = "абвгдеёжзийклмнопрстуфхцчшщъыьэюяАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЫЬЭЮЯ()&"

def print_system(system_name,title,cmdb_mnemonic,status,description,modified,author,puid,ea_guid,domain,path):

    filename = path+'landscape.dsl'
    write_header = False

    if not os.path.exists(filename):
        write_header = True

    with open(filename,"a") as f:
        if write_header:
                f.write ('# Сгененрированный файл для систем ландшафта \n')
                f.write ('# Домен: '+path+'\n\n')
                print("!include "+filename)

        f.write (system_name +' = softwareSystem "'+title+'" {\n')
        f.write ('   description "'+description+'"\n')
        f.write ('   tags "landscape" "'+domain+'"\n')
        f.write ('   properties {\n')
        f.write ('    "cmdb" "'+cmdb_mnemonic+'"\n')
        f.write ('    "status" "'+status+'"\n')
        f.write ('    "author" "'+author+'"\n')
        f.write ('    "puid" "'+puid+'"\n')
        f.write ('    "ea_guid" "'+ea_guid+'"\n')
        f.write ('    "domain" "'+domain+'"\n')
        f.write ('    "modified" "'+modified+'"\n')
        f.write ('   }\n')
        f.write ('}\n')

def mk_dirs(dirs):

    cur = ''
    for a in dirs:
        cur += a
        if not os.path.isdir(cur):
            os.mkdir(cur)
            
        cur += '/'


def main(argv):
    # parse args
    inputfile = ''

    helpstring = 'import_from_json.py -i <inputfile>'
    try:
        opts, args = getopt.getopt(argv,"hp:i:")
    except getopt.GetoptError:
        print (helpstring)
        sys.exit(2)
    for opt, arg in opts:
        if opt == '-h':
            print (helpstring)
            sys.exit()
        elif opt in ("-i"):
            inputfile = arg



    if len(inputfile) == 0:
        print (helpstring)
        sys.exit()
    
    f = open(inputfile)
    data = json.load(f)

    imported = set()
    imported_names = set()

    for item in data:
        puid = item["puid"]
        ea_guid = item["ea_guid"]
        package = item["package"].replace('"','')
        name = item["name"].replace('"','')
        alias = item["alias"]
        description = item["description"].replace('"','').replace('\n',' ')
        author = item["author"]
        status = item["status"]
        modifieddate = item["modifieddate"]
        fullName  = item["fullName"]

        if len(alias)>0:
            has_russian = False
            for c in alias:
                if c in ru_symbols:
                    has_russian = True
                    break
            if (not has_russian) and (not alias in imported) and (not name in imported_names):
                imported.add(alias)
                imported_names.add(name)
                dirs = fullName.split('/')
                dirs = dirs[0:len(dirs)-1]
                dirs = list(d.replace(' ','_').replace('\\','').replace(',','').replace('.','').replace('-','_').replace('(','').replace(')','').replace('"','') for d in dirs)
                mk_dirs(dirs)
                path = ""
                for d in dirs:
                    path += d + '/'
                
                system_name = alias.replace('.','_').replace(' ','_').replace('"','').replace('-','_')
                print_system(system_name,name,alias,status,description,modifieddate,author,puid,ea_guid,package,path)
            #print(dirs)
        #print (item['ea_guid'])
    
    


                

if __name__ == "__main__":
   main(sys.argv[1:])