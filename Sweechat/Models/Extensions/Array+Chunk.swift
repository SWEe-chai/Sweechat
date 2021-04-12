extension Array {
    func chunked(into size: Int) -> [[Element]] {
        stride(from: 0, to: count, by: size).map {
            Array(self[$0 ..< Swift.min($0 + size, count)])
        }
    }
    func firstHalf() -> [Element] {
        let ct = self.count
        let half = ct / 2
        let leftSplit = self[0 ..< half]
        return Array(leftSplit)
    }
}
