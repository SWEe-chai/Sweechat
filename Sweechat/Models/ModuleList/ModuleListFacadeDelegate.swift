/**
 An interface through which the server communicates with the calling `ModuleList` instance.
 */
protocol ModuleListFacadeDelegate: AnyObject {
    func insert(module: Module)
    func insertAll(modules: [Module])
    func remove(module: Module)
}
