protocol MessageActionsViewModelDelegate: AnyObject {
    func edit(messageViewModel: MessageViewModel)
    func delete(messageViewModel: MessageViewModel)
    func toggleLike(messageViewModel: MessageViewModel)
}