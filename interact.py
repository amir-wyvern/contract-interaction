from solcx import compile_source
from web3 import Web3
import json

class Contract:

    def __init__(self, provider, private_key, account_address):

        self.private_key = private_key
        self.account_address = account_address
        
        self.w3 = Web3(Web3.HTTPProvider(provider))

        if not self.w3.is_connected():
            raise "Not Connected To Provider"

        print('connected to web3 successfully')

        with open('contract.json', 'r') as fi:

            data = json.load(fi)

            abi = data['abi']
            address = data['address']

        self.contract = self.w3.eth.contract(abi= abi, address= address)

    def read_data(self):
        
        return self.contract.functions.getVar().call()

    def write_data(self, new_data: int):


        transaction = self.contract.functions.setVar(new_data).build_transaction({
            'from': self.account_address,
            'nonce': self.w3.eth.get_transaction_count(account_address),
            'gas': 200000,  
            'gasPrice': self.w3.to_wei('85', 'gwei')  
        })

        signed_txn = self.w3.eth.account.sign_transaction(transaction, self.private_key)

        print(f'send raw transaction...')

        tx_hash = self.w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        print(f'tx hash: {tx_hash.hex()}\nwaiting for complated...')

        tx_receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)

        if tx_receipt['status'] == 1:
            print('tx Done')

        else:
            print(f'tx is pending to complated with tx_hash: [{tx_hash.hex()}]')


provider = ""
private_key= ""
account_address= ""

contract = Contract(provider= provider, private_key= private_key, account_address= account_address)

# ==== Read Data ====
data = contract.read_data()
print(data)

# ==== Write Data ====
contract.write_data(45)
