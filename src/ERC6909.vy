# @version 0.3.9

event Transfer:
    sender: indexed(address)
    receiver: indexed(address)
    id: indexed(uint256)
    amount: uint256

event OperatorSet:
    owner: indexed(address)
    spender: indexed(address)
    approved: bool

event Approval:
    owner: indexed(address)
    spender: indexed(address)
    id: indexed(uint256)
    amount: uint256

# Keeps track of the amount of a given tokenId that exists
totalSupply: public(HashMap[uint256 tokenId, uint256 supply])

# Maps balance of `owner` and `id` to a `balance` for owner
balanceOf: public(HashMap[address, HashMap[uint256, uint256]])

# Maps allowance of `owner` to `spender` and `id`
allowance: public(HashMap[address, HashMap[address, HashMap[uint256, uint256]]])

# Maps if a spender is approved as an operator for an owner
isOperator: public(HashMap[address, HashMap[address, bool]])


@external
def mint(receiver: address, id: uint256, amount: uint256):
    """
        @param reciever The reciever of the minted tokens
        @param id The id of which the tokens should be minted
        @param amount How many tokens should be minted to `reciever`
    """
    self.totalSupply[id] += amount
    self.balanceOf[receiver][id] += amount
    log Transfer(empty(address), receiver, id, amount)


@pure
@external
def supportsInterface(interfaceId: bytes4) -> bool:
    """
        @param interfaceId The interfaceId in question of beign supported

        @param bool Whether or not the supplied interface is supported
    """
    return interfaceId == 0xb2e69f8a or interfaceId == 0x01ffc9a7


@external
def transfer(receiver: address, id: uint256, amount: uint256):
    """
        @param reciever The reciever of the tokens
        @param id The id of which the tokens should be minted
        @param amount How many tokens should be transfered to `reciever` from msg.sender
    """
    assert self.balanceOf[msg.sender][id] >= amount, "Insufficient balance"
    self.balanceOf[msg.sender][id] -= amount
    self.balanceOf[receiver][id] += amount
    log Transfer(msg.sender, receiver, id, amount)


@external
def transferFrom(sender: address, receiver: address, id: uint256, amount: uint256):
    """
        @param sender Whom the tokens should be transfered from
        @param reciever The reciever of the tokens
        @param id The id of which the tokens should be minted
        @param amount How many tokens should be transfered to `reciever` from msg.sender
    """
    if msg.sender != sender and not self.isOperator[sender][msg.sender]:
        assert self.allowance[sender][msg.sender][id] >= amount, "Insufficient allowance"
        self.allowance[sender][msg.sender][id] -= amount
    assert self.balanceOf[sender][id] >= amount, "Insufficient balance"
    self.balanceOf[sender][id] -= amount
    self.balanceOf[receiver][id] += amount
    log Transfer(sender, receiver, id, amount)


@external
def approve(spender: address, id: uint256, amount: uint256):
    """

    """
    self.allowance[msg.sender][spender][id] = amount
    log Approval(msg.sender, spender, id, amount)


@external
def setOperator(spender: address, approved: bool):
    self.isOperator[msg.sender][spender] = approved
    log OperatorSet(msg.sender, spender, approved)
