pragma solidity ^0.4.0;
pragma experimental ABIEncoderV2;

contract StudentContract {
    Student[] public students;

    struct Student {
        string name;
        uint weight;
        uint height;
        uint age;
    }

    function remove_student(uint id) public returns (Student[]) {
        Student[] memory _students = students;
        while (id < _students.length - 1) {
            _students[id] = _students[id + 1];
            id++;
        }
        students.length--;
        students = _students;
    }
}
