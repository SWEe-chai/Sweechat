/**
 An interface through which the `Module` model comunicates with the server.
 */
protocol ModuleFacade {
    var delegate: ModuleFacadeDelegate? { get set }
    func save(chatRoom: ChatRoom,
              userPermissions: [UserPermissionPair],
              onCompletion: (() -> Void)?)
}
