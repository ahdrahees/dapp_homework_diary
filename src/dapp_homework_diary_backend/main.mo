import Time "mo:base/Time";
import Buffer "mo:base/Buffer";
import Result "mo:base/Result";
import Text "mo:base/Text";
import Array "mo:base/Array";
import HashMap "mo:base/HashMap";
import Principal "mo:base/Principal";
import Debug "mo:base/Debug";
import Nat "mo:base/Nat";
import Iter "mo:base/Iter";
import TrieMap "mo:base/TrieMap";

actor class Homework() {

  public type Time = Time.Time;

  public type Homework = {
    title : Text;
    description : Text;
    dueDate : Time;
    completed : Bool;

  };

  type HWDiaryBuffer = Buffer.Buffer<Homework>;
  // Buffer.Buffer<Homework> is buffer data structure of type Homework,
  // Buffer.Buffer<Homework>(0) is buffer creating with from Homework type

  // All types should be stable when declaring a stable variable . So we have to convert each and every non stable types(Hashmap, Buffer ..etc) into stable types (Array, Nat, Text ...etc)

  stable var dataOfUsers : [(Principal, [Homework])] = [];
  let userLoginMap = HashMap.HashMap<Principal, HWDiaryBuffer>(0, Principal.equal, Principal.hash);

  // var dataArray : [(Principal, HWDiaryBuffer)] = [];
  // let userLoginMap = HashMap.fromIter<Principal, HWDiaryBuffer>(dataArray.vals(), dataArray.size(), Principal.equal, Principal.hash);

  // let userLoginMap = TrieMap.fromEntries<Principal, HWDiaryBuffer>(dataArray.vals(), Principal.equal, Principal.hash);

  /////////////////////////////////////////////////////////////////////////////////////////////////////////////
  //////////////////////////////////////////////Public Functions///////////////////////////////////////////////
  /////////////////////////////////////////////////////////////////////////////////////////////////////////////

  // Add a new homework task
  public shared ({ caller }) func addHomework(_homeWork : Homework) : async Nat {
    switch (userLoginMap.get(caller)) {
      case (null) {
        let homeworkDiary : HWDiaryBuffer = Buffer.Buffer<Homework>(0);
        homeworkDiary.add(_homeWork);
        userLoginMap.put(caller, homeworkDiary);
        return homeworkDiary.size() -1;
      };
      case (_) {
        let homeworkDiary : HWDiaryBuffer = switch (userLoginMap.get(caller)) {
          case (?hwDiary) { hwDiary };
          case (null) { Debug.trap("Value was null") };
        };
        homeworkDiary.add(_homeWork);
        userLoginMap.put(caller, homeworkDiary);
        return homeworkDiary.size() -1;
      };
    };

  };

  // Get a specific homework task by id
  public shared ({ caller }) func getHomework(homeworkId : Nat) : async Result.Result<Homework, Text> {
    switch (userLoginMap.get(caller)) {
      case (null) {
        return #err("You have no Homework created yet");
      };
      case (?homeworkDiary) {
        switch (homeworkDiary.getOpt(homeworkId)) {
          case (?homework) { return #ok(homework) };
          case (null) { return #err("Invalid Homework Id") };
        };
      };
    };
  };

  // Update a homework task's title, description, and/or due date
  public shared ({ caller }) func updateHomework(homeworkId : Nat, _homeWork : Homework) : async Result.Result<(), Text> {
    switch (userLoginMap.get(caller)) {
      case (null) {
        return #err("You have no Homework created yet");
      };
      case (?homeworkDiary) {
        switch (homeworkDiary.getOpt(homeworkId)) {
          case (null) { return #err("Invalid Homework Id") };
          case (_) { #ok(homeworkDiary.put(homeworkId, _homeWork)) };
        };
      };
    };
  };

  // Mark a homework task as completed
  public shared ({ caller }) func markAsCompleted(homeworkId : Nat) : async Result.Result<(), Text> {
    switch (userLoginMap.get(caller)) {
      case (null) {
        return #err("You have no Homework created yet");
      };
      case (?homeworkDiary) {
        switch (homeworkDiary.getOpt(homeworkId)) {
          case (?hw) {
            let completedHomework : Homework = {
              title = hw.title;
              description = hw.description;
              dueDate = hw.dueDate;
              completed = true;
            };
            #ok(homeworkDiary.put(homeworkId, completedHomework));
          };
          case (null) { return #err("Invalid Homework Id") };
        };
      };
    };
  };

  // Delete a homework task by id
  public shared ({ caller }) func deleteHomework(homeworkId : Nat) : async Result.Result<(), Text> {
    switch (userLoginMap.get(caller)) {
      case (null) {
        return #err("You have no Homework created yet");
      };
      case (?homeworkDiary) {
        switch (homeworkDiary.getOpt(homeworkId)) {
          case (?hw) {
            let _deletedHomework = homeworkDiary.remove(homeworkId);
            return #ok;
          };
          case (null) { return #err("Invalid Homework Id") };
        };
      };
    };
  };

  // Get the list of all homework tasks
  public shared query ({ caller }) func getAllHomework() : async [Homework] {
    switch (userLoginMap.get(caller)) {
      case (null) {
        return [];
        // return #err("You have no Homework created yet");
      };
      case (?homeworkDiary) {
        let homeworkArray : [Homework] = Buffer.toArray(homeworkDiary);
        return homeworkArray;
      };
    };
  };

  // Get the list of pending (not completed) homework tasks
  public shared query ({ caller }) func getPendingHomework() : async [Homework] {
    switch (userLoginMap.get(caller)) {
      case (null) {
        return [];
        // return #err("You have no Homework created yet");
      };
      case (?homeworkDiary) {
        let pendingHomework = Buffer.mapFilter<Homework, Homework>(
          homeworkDiary,
          func(hw) {
            if (not hw.completed) {
              ?hw;
            } else {
              null;
            };
          },
        );
        if (pendingHomework.size() != 0) {
          return Buffer.toArray(pendingHomework);
        } else {
          return [];
        };
      };
    };
  };

  // Search for homework tasks based on a search terms
  public shared query ({ caller }) func searchHomework(searchTerm : Text) : async [Homework] {
    switch (userLoginMap.get(caller)) {
      case (null) {
        return [];
        // return #err("You have no Homework created yet");
      };
      case (?homeworkDiary) {
        let searchHomework = Buffer.mapFilter<Homework, Homework>(
          homeworkDiary,
          func(hw : Homework) {
            if (Text.contains(hw.description, #text searchTerm) or Text.contains(hw.title, #text searchTerm)) {
              ?hw;
            } else {
              null;
            };
          },
        );
        return Buffer.toArray(searchHomework);
      };
    };
  };

  // Delete user account (Note: Deleting a user account can only be done by the user himself)
  public shared ({ caller }) func deleteUser() : async Result.Result<Bool, Text> {
    switch (userLoginMap.get(caller)) {
      case (null) {
        return #err("You don't have account to delete");
      };
      case (_) {
        userLoginMap.delete(caller);
        return #ok(true);
      };
    };
  };

  // Get the user principal
  public shared query ({ caller }) func user() : async Principal {
    return caller;
  };

  // Get number of Homeworks created by caller or user
  public shared query ({ caller }) func getNumberOfHomeworksOfUser() : async Nat {
    switch (userLoginMap.get(caller)) {
      case (null) { return 0 };
      case (?homeworkDiary) { return homeworkDiary.size() };
    };
  };

  // Get number of users of this Homework diary dapp
  public shared query func getNumberOfUsers() : async Nat {
    return userLoginMap.size();
  };

  // Get Totall number of Homework created by all users
  public shared query func getTotalNumberofHomeworks() : async Nat {
    var numberOFHomeworks = 0;
    for (homeworkDiary in userLoginMap.vals()) {
      numberOFHomeworks += homeworkDiary.size();
    };
    return numberOFHomeworks;
  };

  // Check a Principle is the user of Homework diary or not
  public shared query func isUserOrNot(principal : Principal) : async Bool {
    switch (userLoginMap.get(principal)) {
      case (null) {
        return false;
      };
      case (_) {
        return true;
      };
    };
  };

  // Get current Time
  public shared query func currentTime() : async Time {
    return Time.now();
  };

  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////
  ///////////////////////////////////////////////Upgrade Functions///////////////////////////////////////////////
  ///////////////////////////////////////////////////////////////////////////////////////////////////////////////

  system func preupgrade() {
    preupgradeDataSync();
  };

  system func postupgrade() {
    // dataOfUsers := [];
    postupgradeDataSync();
  };

  func preupgradeDataSync() {
    let dataBuffer = Buffer.Buffer<(Principal, [Homework])>(0);
    for ((userPrincipal, homeworkDiary) in userLoginMap.entries()) {

      dataBuffer.add(userPrincipal, Buffer.toArray(homeworkDiary));
    };
    dataOfUsers := Buffer.toArray(dataBuffer);
  };

  func postupgradeDataSync() {
    // let bufferOfUserData = Buffer.Buffer<(Principal, HWDiaryBuffer)>(0);
    for ((userPrincipal, homeworkDiary) in dataOfUsers.vals()) {
      userLoginMap.put((userPrincipal, Buffer.fromArray(homeworkDiary)));
    };
    // dataArray := Buffer.toArray<(Principal, HWDiaryBuffer)>(bufferOfUserData);
  };

};
