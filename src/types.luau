export type key = string
export type uuid = string | number

export type write<T> = (value : T, size : number?) -> ()
export type read<T> = (buffer : buffer, cursor : number, size : number?) -> T
export type map<T> = {[key] : dataType<T>}

export type dataType<T> = {
    write : write<T>,
    read : read<T>,
    sample : T,
    id : string,
}

export type change = {
    key : string,
    action : "ADDED" | "REMOVED" | "CHANGED",
    dataType : dataType<any>,
}

export type changeLog = {change}

export type schemaMeta = {
    latestVersion : number,
    base : map<any>,
}

export type schema = {
    
}

export type Group<T> = {
    new : (uuid : uuid) -> uuid,
    del : (uuid : uuid) -> (),
    set : (uuid : uuid, key : string, data : T) -> (),
    get : (uuid : uuid, key : string) -> T?,
}


return nil