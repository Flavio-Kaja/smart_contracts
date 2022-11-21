//SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.0;
import "../node_modules/@openzeppelin/contracts/access/AccessControl.sol";

/**
 *Contrct used to define and set the role behaviours in our system
 *It is the first contract deployed as it serves as a primary dependency for the rest of the contrats
 */
contract Administration is AccessControl {
  bytes32 public constant Student = keccak256("STUDENT"); //setting up the student role
   bytes32 public constant Teacher = keccak256("TEACHER"); //setting up the student role

  /// @dev Add `root` to the admin role as a member.
  constructor  ()
    
  {
    _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);    
    _setRoleAdmin(Student, DEFAULT_ADMIN_ROLE); // set the default admin role as the admin role for the student role
     _setRoleAdmin(Teacher, DEFAULT_ADMIN_ROLE); // set the default admin role as the admin role for the teacher role
  }

     
 /// @dev Only Administrator accounts can undergo the specified action
  modifier onlyAdmin()
  {
    require(isAdmin(msg.sender), "Requires administrator account.");
    _;
  }

  /// @dev Only Student accounts can undergo the specified action
  modifier onlyStudents()
  {
    require(isStudent(msg.sender), "Requires student account.");
    _;
  }

  /// @dev Only Student accounts can undergo the specified action
  modifier onlyTeachers()
  {
    require(isTeacher(msg.sender), "Requires teacher account.");
    _;
  }

  function showSender() public view returns (address)  
{  
    return (msg.sender);  
}

  /// @dev Check if the account has the Admin role.
   function isAdmin(address account)
    public virtual view returns (bool)
  {
    return hasRole(DEFAULT_ADMIN_ROLE, account);
  }

  /// @dev Check if the account has the student role.
  function isStudent(address account)
    public virtual view returns (bool)
  {
    return hasRole(Student, account);
  }

   /// @dev Check if the account has the teacher role
  function isTeacher(address account)
    public virtual view returns (bool)
  {
    return hasRole(Teacher, account);
  }

  /// @dev Grand the student role to the given address
  function addStudent(address account)
    public virtual onlyAdmin
  {
    grantRole(Student, account);
    message = "student registered";
  }

   /// @dev Grand the Teacher role to the given address
  function addTeacher(address account)
    public virtual onlyAdmin
  {
    grantRole(Teacher, account);
  }


  /// @dev Add an account to the admin role. Restricted to admins.
  function addAdmin(address account)
    public virtual onlyAdmin
  {
    grantRole(DEFAULT_ADMIN_ROLE, account);
  }

  /// @dev Remove the student role from the given account
  function removeStudent(address account)
    public virtual onlyAdmin
  {
    revokeRole(Student, account);
  }
    /// @dev Add an account to the admin role. Restricted to admins.
  function addAdmin()
    public virtual 
  {
    grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
  }
string public message;
   /// @dev Remove the teacher role from the given account
  function removeTeacher(address account)
    public virtual onlyAdmin
  {
    revokeRole(Teacher, account);
  }

}