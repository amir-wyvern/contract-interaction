from web3 import Web3
import json

class DiamondContract:

    def __init__(self, provider, private_key, account_address, contract_address):

        self.private_key = private_key
        self.account_address = account_address
        self.contract_address = contract_address

        self.w3 = Web3(Web3.HTTPProvider(provider))

        if not self.w3.is_connected():
            raise "Not Connected To Provider"

        print('connected to web3 successfully')

        with open('contract.json', 'r') as fi:

            data = json.load(fi)

            abi = data['abi']

        self.contract = self.w3.eth.contract(abi= abi, address= self.contract_address)

    def read_gc_status(self, address):
        
        return self.contract.functions.checkGC(address).call()

    def register_gc(self, address: str):

        transaction = self.contract.functions.registerGC(address).build_transaction({
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

    def revoke_gc(self, address: str):

        transaction = self.contract.functions.revokeGC(address).build_transaction({
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

contract_address= ""

contract = DiamondContract(provider= provider, private_key= private_key, account_address= account_address, contract_address= contract_address)

# ==== Write Data ====
# contract.registerGC('0x93d61f3Ee47eDDc266653017801600e75BCc22ef')
# contract.revokeGC('0x93d61f3Ee47eDDc266653017801600e75BCc22ef')

# ==== Read Data ====
data = contract.read_gc_status('0xE9B4b5DF008B33902317A44C1393B1703F7dF90f')
print(data)

