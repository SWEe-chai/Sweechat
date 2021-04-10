protocol MessageActionsViewModelDelegate: AnyObject {
    func edit(message: Message)
    func delete(message: Message)
}
