/**
 An interface through which the `ModuleList` model comunicates with the server.
 */
protocol ModuleListFacade {
    var delegate: ModuleListFacadeDelegate? { get set }
    func save(module: Module, userModulePermissions: [UserModulePermissionPair])
    func joinModule(moduleId: Identifier<Module>)
}
