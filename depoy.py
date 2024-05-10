from web3 import Web3
import solcx
import json

class Contract:

    def __init__(self, provider, private_key, account_address):

        self.private_key = private_key
        self.account_address = account_address
        self.w3 = Web3(Web3.HTTPProvider(provider))

        if not self.w3.is_connected():
            raise "Not Connected To Provider"

        print('connected to web3 successfully')

    def compile_source_file(self):

        if '0.8.20' not in [str(version) for version in solcx.get_installed_solc_versions()]:
            solcx.install_solc('0.8.20')

        with open('contract.sol', 'r') as f:
            source = f.read()

        solcx.set_solc_version('0.8.20')
        
        return solcx.compile_source(source,output_values=['abi','bin'], evm_version="london")

    def save_contract_json(self, abi, address):

        data = {
            'address': address,
            'abi': abi
        }

        with open('contract.json', 'w') as fi:
            json.dump(data, fi)

    def deploy_contract(self):

        compiled_sol = self.compile_source_file()

        contract_id, contract_interface = compiled_sol.popitem()
        
        contract = self.w3.eth.contract(abi=contract_interface['abi'], bytecode=contract_interface['bin'])
        
        transaction = contract.constructor().build_transaction({
            'from': self.account_address,
            'nonce': self.w3.eth.get_transaction_count(account_address),
            'gas': 2000000,  
            'gasPrice': self.w3.to_wei('60', 'gwei')  
        })

        signed_txn = self.w3.eth.account.sign_transaction(transaction, self.private_key)

        print(f'send raw transaction...')

        tx_hash = self.w3.eth.send_raw_transaction(signed_txn.rawTransaction)
        print(f'tx hash: {tx_hash.hex()}\nwaiting for complated...')

        tx_receipt = self.w3.eth.wait_for_transaction_receipt(tx_hash)
        print(f'tx Done\ncontract address: {tx_receipt["contractAddress"]}')

        if tx_receipt['status'] == 1:
            self.save_contract_json(abi= contract_interface['abi'], address= tx_receipt['contractAddress'])

0x4f3edf983ac636a65a842ce7c78d9aa706d3b113bce9c46f30d7d21715b23b1d
        else:
            print(f'Contract tx is pending to complated with tx: [{tx_hash.hex()}]')


provider = ""
private_key= ""
account_address= ""

contract = Contract(provider= provider, private_key= private_key, account_address= account_address)
contract.deploy_contract()


