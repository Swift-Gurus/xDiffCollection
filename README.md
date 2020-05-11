# xDiffCollection
[![Build Status](https://app.bitrise.io/app/0cd2520108d5ffa0/status.svg?token=6rT8f0dG3yMAqW9NyiUalg&branch=master)](https://app.bitrise.io/app/0cd2520108d5ffa0)
[![License](https://img.shields.io/cocoapods/l/SwiftyCollection.svg?style=flat)](https://cocoapods.org/pods/xDiffCollection)
[![Documentation](https://swift-gurus.github.io/xDiffCollection/badge.svg)](https://swift-gurus.github.io/xDiffCollection)


## Description
`Diff` is a concept of a container for multiple collections and provides methods to access elements of those collections
  *Example*:
   ````swift
       let names = ["Adams", "Bryant", "Channing"]
       let cars = ["Ford", "Dodge"]
       let collection = Diff([names,cars])
       let subSequence = collection[1]
       print(subSequence)
       // ["Ford", "Dodge"]
   
       let element = collection[IndexPath(row: 0,section: 1)]
       print(element)
       // "Ford"
   ````


 Contains a very powerful **extension** for `Diff`where  `C` == [`CollectionBin<[T]>`] that
 provides logic for updating element and putting it in propper subcollections of type `CollectionBin<[T]>`

 An update operation returns `DiffCollectionSnapshot<T>` containing modifications made to the collection and
 its subcollections.

   **Usage Example**
   - Define a model
   ````swift
      //let's have a model like
      struct TestObject: Hashable, Equatable {
           var value: String
           var status: ObjectStatus
           var rank: Int

           
           func hash(into hasher: inout Hasher) {
               hasher.combine(value)
               hasher.combine(rank)
           }

          // -Note: since value and rank are a part of unique value of the object the only part that
          // cab be changed is the status
           static func == (lhs: Self, rhs: Self) -> Bool {
               lhs.status  == rhs.status
           }
      }
   ````
   - Define filters for sections:
   
   ````swift
        let startsARankSorted = DiffCollectionFilter<TestObject>(name: "Starts with a",
                                                                 filter: { $0.value.starts(with: "a") },
                                                                 sort: { $0.rank > $1.rank })

        let startedBValueSorted = DiffCollectionFilter<TestObject>(name: "Starts with b",
                                                                   filter: { $0.value.starts(with: "b") },
                                                                   sort: { $0.value > $1.value })
   ````
       
   - initialize `Diff`
   
   ````swift
       var diffCollection = [startsARankSorted, startedBValueSorted]

   ````
   
   - Start using by calling upade function
   
   ````swift
       let elementA = TestObject(value: "Arm",
                                 status: .new,
                                 rank: 100)
       let snapshot = diffCollection.update(with: elementA)
       debugPrint(snapshot.changes)
       // updatedIndexes = [], removedIndexes = [], addedIndexes = [IndexPath(row: 0, section: 0)]
       
   ````

## Documentaion 
For more information check the [documentaion page](https://swift-gurus.github.io/xDiffCollection/)

## Author

Swift-Gurus Inc., alexei.hmelevski@gmail.com

## License

xDiffCollection is available under the MIT license. See the LICENSE file for more info.
