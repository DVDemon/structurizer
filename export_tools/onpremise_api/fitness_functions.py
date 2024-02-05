def get_functions():
    return ['deploy']

def error(list,message):
    print('- '+message)
    list.append(message)

def deploy(data):
    errors              = list()
    model               = data['model']
    views               = data['views']
    persons             = dict()
    systems             = dict()
    containers          = dict()
    components          = dict()

    if 'people' in model:
        people = model['people']

        for p in people:
            persons[p['id']]= p

    if 'softwareSystems' in model:
        software_systems    = model['softwareSystems'] # Системы  


       
    
        for s in software_systems:
            systems[s['id']] = s
            if 'containers' in s:
                for c in s['containers']:
                    containers[c['id']]=c
                    if 'components' in c:  
                        for cc in c['components']:
                            components[cc['id']]=cc


        # Check CMDB ------------------------

        used_systems = set()
        if 'systemContextViews' in views:
            context_views = views['systemContextViews']
            for v in context_views:
                for element in v['elements']:
                    id = element['id']
                    if id in systems:
                        s = systems[id]
                        used_systems.add(s['id'])

        if 'systemLandscapeViews' in views:
            context_views = views['systemLandscapeViews']
            for v in context_views:
                for element in v['elements']:
                    id = element['id']
                    if id in systems:
                        s = systems[id]
                        used_systems.add(s['id'])
        
        for s_id in used_systems:
            s = systems[s_id]
            if 'properties' in s:
                properties = s['properties']
                if not 'cmdb' in properties:
                    is_external = False
                    if 'type' in properties:
                        if properties['type'] == 'external':
                            is_external = True
                   
                    if not is_external:
                        error(errors,'Property CMDB для системы ['+s['name']+'] не существует')

        # Check technology on relations ------------------------
        bad_relations = set()
        for s in software_systems:
            if 'relationships' in s:
                relationships = s['relationships']
                for r in relationships:
                   
                    sourceId        = r['sourceId']
                    destinationId   = r['destinationId']
                    if not sourceId+':'+destinationId in bad_relations:
                        if (not sourceId in persons) and (not destinationId in persons):
                            source_name      = ''
                            destination_name = ''
                            description      = ''
                            if 'description' in r:
                                description      = r["description"]
                                
                            if sourceId in systems:
                                source_name = systems[sourceId]['name']
                            if destinationId in systems:
                                destination_name = systems[destinationId]['name']
                            
                            if sourceId in containers:
                                source_name = containers[sourceId]['name']
                            if destinationId in containers:
                                destination_name = containers[destinationId]['name']

                            if sourceId in components:
                                source_name = components[sourceId]['name']
                            if destinationId in components:
                                destination_name = components[destinationId]['name']
                            
                            if 'technology' in r:
                                technology = r['technology']
                                if not ':' in technology:
                                    error(errors,f'relation: Не указан сетевой порт для вызова {description} [{source_name}->{destination_name}]')
                                    bad_relations.add(sourceId+':'+destinationId)
                            else:
                                error(errors,f'relation: Не указана технология для вызова {description} [{source_name}->{destination_name}]')
                                bad_relations.add(sourceId+':'+destinationId)



        # Check deployment ------------------------
        if 'deploymentNodes' in model:
            deployment_nodes    = model['deploymentNodes'] # Стенды

            has_production = False
            for d_node in deployment_nodes:
                if not 'children' in d_node:
                    has_os   = False
                    has_cpu  = False
                    has_ram  = False
                    if 'properties' in d_node:
                        properties = s['properties']
                        if 'os' in properties: 
                            has_os = True
                        if 'cpu' in properties: 
                            has_cpu = True
                        if 'ram' in properties:
                            has_ram = True

                    if not has_os:
                        error(errors,f'Не указана операционная система для {d_node["name"]}')
                    if not has_cpu:
                        error(errors,f'Не указаны требования к CPU для {d_node["name"]}')
                    if not has_ram:
                        error(errors,f'Не указаны требования к RAM для {d_node["name"]}')

                if d_node['environment'] == 'Production':
                    has_production = True
                    
            if not has_production:    
                error(errors,'Диаграмма развертывания для среды Production не существует')
        else:
            error(errors,'Диаграмма развертывания не существует')
            
    else:
        error(errors,'В модели нет систем')

    return errors
    

def context(data):
    errors              = list()
    model               = data['model']
    views               = data['views']
    persons             = dict()
    systems             = dict()
    containers          = dict()
    components          = dict()

    if 'people' in model:
        people = model['people']

        for p in people:
            persons[p['id']]= p

    if 'softwareSystems' in model:
        software_systems    = model['softwareSystems'] # Системы  

    
        for s in software_systems:
            systems[s['id']] = s
            if 'containers' in s:
                for c in s['containers']:
                    containers[c['id']]=c
                    if 'components' in c:  
                        for cc in c['components']:
                            components[cc['id']]=cc


        # Check CMDB ------------------------

        used_systems = set()
        if 'systemContextViews' in views:
            context_views = views['systemContextViews']
            for v in context_views:
                for element in v['elements']:
                    id = element['id']
                    if id in systems:
                        s = systems[id]
                        used_systems.add(s['id'])

        if 'systemLandscapeViews' in views:
            context_views = views['systemLandscapeViews']
            for v in context_views:
                for element in v['elements']:
                    id = element['id']
                    if id in systems:
                        s = systems[id]
                        used_systems.add(s['id'])
        
        for s_id in used_systems:
            s = systems[s_id]
            if 'properties' in s:
                properties = s['properties']
                if not 'cmdb' in properties:
                    is_external = False
                    if 'type' in properties:
                        if properties['type'] == 'external':
                            is_external = True
                   
                    if not is_external:
                        error(errors,'Property CMDB для системы ['+s['name']+'] не существует')

        # Check technology on relations ------------------------
        bad_relations = set()
        for s in software_systems:
            if 'relationships' in s:
                relationships = s['relationships']
                for r in relationships:
                   
                    sourceId        = r['sourceId']
                    destinationId   = r['destinationId']
                    if not sourceId+':'+destinationId in bad_relations:
                        if (not sourceId in persons) and (not destinationId in persons):
                            source_name      = ''
                            destination_name = ''
                            if sourceId in systems:
                                source_name = systems[sourceId]['name']
                            if destinationId in systems:
                                destination_name = systems[destinationId]['name']
                            
                            if sourceId in containers:
                                source_name = containers[sourceId]['name']
                            if destinationId in containers:
                                destination_name = containers[destinationId]['name']

                            if sourceId in components:
                                source_name = components[sourceId]['name']
                            if destinationId in components:
                                destination_name = components[destinationId]['name']
                            
                            if 'technology' in r:
                                technology = r['technology']
                                if not ':' in technology:
                                    error(errors,f'relation: Не указан сетевой порт для вызова {r["description"]} [{source_name}->{destination_name}]')
                                    bad_relations.add(sourceId+':'+destinationId)
                            else:
                                error(errors,f'relation: Не указана технология для вызова {r["description"]} [{source_name}->{destination_name}]')
                                bad_relations.add(sourceId+':'+destinationId)
            
    else:
        error(errors,'В модели нет систем')

    return errors