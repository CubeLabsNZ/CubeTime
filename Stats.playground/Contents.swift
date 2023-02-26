import BTree

var best: Float = Float.greatestFiniteMagnitude

var sum: Float

func getTrimSizeEachEnd(_ n: Int) -> Int {
    print(Int(n/20))
    return (n <= 12) ? 1 : Int(n / 20)
}

func getBestAverage(of width: Int, in solves: [Float]) -> Float {
    var solves: Array<Float>
    var multiset: SortedBag<Float> = SortedBag()
    
    precondition(width >= 5)
    
    let trimSize: Int = getTrimSizeEachEnd(width)
    
    // width of window - 1
    let beginWidth: Int = (width - trimSize)
    
    for i in 0 ..< beginWidth {
        var value: Float = solves[i]
        sum += value
        multiset.insert(value)
    }

    // rest of solves
    for i in beginWidth ..< solves.count {
        var value: Float = solves[i]
        sum += value
        multiset.insert(value)
        
        var sumTrimmed: Float = 0
        
        // for ao5, ao12
        if (trimSize == 1) {
            sumTrimmed = multiset.first! + multiset.last!
        } else {  // for ao>12
            let sumFastest = multiset.prefix(trimSize).reduce(0, {$0 + $1})
            sumTrimmed = multiset.suffix(trimSize).reduce(sumFastest, {$0 + $1})
        }
        
        // todo add error checking
        let average: Float = (sum - sumTrimmed) / Float(width - (trimSize * 2))
        
        best = min(best, average)
        
        sum -= solves[i - width + 1]
        multiset.remove(solves[i - width + 1])
    }
}


getBestAverage(of: 5, in: [0.712, 0.823, 0.163, 10.889, 2.042])
