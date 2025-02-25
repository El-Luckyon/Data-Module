export type key = string
export type uuid = string | number

export type dataType<T> = {
    write : (buffer : buffer, cursor : number, value : T, size : number?) -> (),
    read : (buffer : buffer, cursor : number, size : number?) -> T,
    size : (sample : T) -> number,
}

export type schemaMeta = {

}

export type schema = {
    
}

export type dataType = {

}

export type Group<T> = {
    new : (uuid : uuid) -> uuid,
    del : (uuid : uuid) -> (),
    set : (uuid : uuid, key : string, data : T) -> (),
    get : (uuid : uuid, key : string) -> T?,
}


return nil