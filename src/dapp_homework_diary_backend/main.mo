import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";



actor class Homework() {

public type Time = Time.Time;

  public type Homework = {
    title : Text ;
    description : Text;
    dueDate : Time;
    completed : Bool;

  };

  let userLoginMap = HashMap.HashMap<Principal,Buffer.Buffer<Homework>>(0,Principal.equal,Principal.hash);
  // homeworkDiary
  // let homeworkDiary = Buffer.Buffer<Homework>(0);

  // Add a new homework task
  public shared ({caller}) func addHomework(_homeWork : Homework, userPrincipal: Principal) : async Nat {

    switch (userLoginMap.get(caller)) {
      case (null) {
        let homeworkDiary = Buffer.Buffer<Homework>(0);
        homeworkDiary.add(_homeWork);
        userLoginMap.put(caller,homeworkDiary);
        return homeworkDiary.size() -1;
      };
      case (_) {
        let homeworkDiary : Buffer.Buffer<Homework> = switch(userLoginMap.get(caller)){ case (?hwDiary) {hwDiary}; case (null) { Debug.trap("Value was null")}};
        homeworkDiary.add(_homeWork);
        userLoginMap.put(caller,homeworkDiary);
        return homeworkDiary.size() -1;
      };
    };

    
  };

  // Get a specific homework task by id
  // query func getHomework(user : Principal, homeworkId : Nat) : async ?Homework {

  //   let homeworkDiary : Buffer.Buffer<Homework> = switch(userLoginMap.get(user)){ case (?hwDiary) {hwDiary}; case (null) { Debug.trap("Value was null")}};
  //   let homework = homeworkDiary.getOpt(homeworkId);
  //     // let homework = homeworkDiary.get(homeworkId); not optional
  //   return homework;
  // };

  // public shared ({caller}) func getAHomework((homeworkId : Nat )) : async Result.Result<Homework, Text> {
  //   switch (userLoginMap.get(caller)) {
  //     case (null) {
  //       return #err("You have no Homework created yet");
  //     };
  //     case (homeworkDiary) {
  //       // let _homework = getHomework(caller, homeworkId);
  //       switch(getHomework(caller, homeworkId)){
  //         case (?homework) {
  //           return #ok(homework);
  //         };
  //         case (null)  {
  //           return #err("Invalid Homework Id");
  //         };
  //       };
        
  //     };
  //   };

  // };

  public shared ({caller}) func getA2Homework(homeworkId : Nat ) : async Result.Result<Homework, Text> {
      switch (userLoginMap.get(caller)) {
        case (null) {
          return #err("You have no Homework created yet");
        };
        case (homeworkDiary) {
          
          let  homework = switch(homeworkDiary.getOpt(homeworkId)){ case (?hw) {hw}; case (null) { return #err("Invalid Homework Id"); }};
          
          return #ok(homework);
        };
      };
    };

// Update a homework task's title, description, and/or due date
//   public shared func updateHomework(homeworkId : Nat, _homeWork : Homework ) : async Result.Result<(),Text> {

//     if ( homeworkDiary.getOpt(homeworkId) != null) {
//       #ok(homeworkDiary.put(homeworkId, _homeWork))  
//     }else {
//       return #err("Invalid Homework Id");  
//     };

//   };

// // Mark a homework task as completed
//   public shared func markAsCompleted(homeworkId : Nat) : async Result.Result<(),Text> {

//     if ( homeworkDiary.getOpt(homeworkId) != null) {
    
//       let _homeWork : Homework = homeworkDiary.get(homeworkId);

//       let completedHomework : Homework = {
//           title = _homeWork.title ;
//           description = _homeWork.description;
//           dueDate = _homeWork.dueDate;
//           completed = true;
//       };

//      #ok( homeworkDiary.put(homeworkId,completedHomework))

//     } else {
//       return #err("Invalid Homework Id");  
//     };
//   };

//   // Delete a homework task by id
//   public shared func deleteHomework(homeworkId : Nat) : async Result.Result<(),Text>  {
//     if ( homeworkDiary.getOpt(homeworkId) != null) {
      
//       let _deletedHomework = homeworkDiary.remove(homeworkId);
//       return #ok;
       
//     }else {
//       return #err("Invalid Homework Id"); 
//     };

//   };

//   // Get the list of all homework tasks
//   public shared query func getAllHomework() : async [Homework] {
    
//     let homeworkArray : [Homework] = Buffer.toArray(homeworkDiary);

//     return homeworkArray;
//   };

// // Get the list of pending (not completed) homework tasks
//   public shared query func getPendingHomework() : async  [Homework] {
          
//           let pendingHomework = Buffer.mapFilter<Homework, Homework>(homeworkDiary, func (hw) {
//             if (not hw.completed) {
//                 ?hw;
//              } else {
//                    null;
//              }
//              });

//           if (pendingHomework.size() !=0){
//             return Buffer.toArray(pendingHomework);
//           } else{
//             return [];
//           }
//        };
 
//   // Search for homework tasks based on a search terms
//   public shared query func searchHomework(searchTerm : Text) : async [Homework] {

//       // hw is homework Type Homework. hw is considered a element in array
//       let searchHomework = Buffer.mapFilter<Homework, Homework>(homeworkDiary, func(hw: Homework){
        
//         if( Text.contains(hw.description, #text searchTerm) or Text.contains(hw.title, #text searchTerm) ){
//              ?hw
//         } else {
//           null;
//         } 
//       });

//       return Buffer.toArray(searchHomework);

//   };

};