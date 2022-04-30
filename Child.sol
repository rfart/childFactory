// SPDX-License-Identifier: Unidentified
pragma solidity 0.8.7;


contract Child {
    uint childNumber;
    constructor(uint _x){
        childNumber = _x;
    }
}


contract ChildFactory{
    Child[] public children;
    mapping(uint => address) public ownerOfChild;
    event childCreated(
        uint _timeStamp,
        uint _childNumber,
        address _childAddress,
        address _owner
    );

    // Fill index[0] of children
    constructor(){
        Child child = new Child(0);
        children.push(child);
    }
    
    // Number of children were created
    function getChildNumber()private view returns(uint) {
        return children.length;
    }

    // @param justCreate: ignore the childrens with no owner and just create a new children
    // @param justCreate: if false, it will adopt 1 of the oldest children with no owner
    // or create new children if all childrens were have owner
    function createOrAdoptChild(bool justCreate)external{
        if(justCreate){
            uint number = getChildNumber();
            Child child = new Child(number);
            children.push(child);
            ownerOfChild[number] = msg.sender;
            emit childCreated(block.timestamp, number, address(child), msg.sender);
        }else{
            uint length = children.length;
            for(uint i = 1; i <= length;){
                if(i == length){
                    uint number = getChildNumber();
                    Child child = new Child(number);
                    children.push(child);
                    ownerOfChild[number] = msg.sender;
                    emit childCreated(block.timestamp, number, address(child), msg.sender);
                }
                else if(ownerOfChild[i] == address(0)){
                    ownerOfChild[i] = msg.sender;
                    return;
                }
                unchecked{++i;}
            }
        }

    }

    function deleteChild(uint index)external{
        require(ownerOfChild[index] == msg.sender, 'Not your child');
        delete ownerOfChild[index];
    }
    function transferChild(address to, uint index)external{
        require(ownerOfChild[index] == msg.sender, 'Not your child');
        ownerOfChild[index] = to;
    }
}