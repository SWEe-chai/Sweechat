protocol MessageActionsViewModelDelegate: AnyObject {
    func delete(messageViewModel: MessageViewModel)
    func toggleLike(messageViewModel: MessageViewModel)
}
