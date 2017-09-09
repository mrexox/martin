// -*- mode: rjsx -*-

const MESVIEW = 0;
const ORDSVIEW = 1;

class Console extends React.Component {
	constructor(props) {
		super(props);
		this.requestDoneOrders = this.requestDoneOrders.bind(this);
		this.requestMessages = this.requestMessages.bind(this);
		this.changeView = this.changeView.bind(this);		
		this.delMessCallback = this.delMessCallback.bind(this);
		
		this.state = {
			view: ORDSVIEW,
			orders: [],
			messages: []
		};
		this.requestDoneOrders();
		this.requestMessages();
	}

	requestDoneOrders() {
		let _this = this;
		$.getJSON("/console/done-orders", function(data) {
			_this.setState({orders: data.done_orders});
		});
	}

	requestMessages() {
		var _this = this;
		$.getJSON("/console/messages", function(data) {
			_this.setState({messages: data.messages});
		});
	}
	
	changeView(view) {
		this.setState({view: view});
	}

	delMessCallback(messageId) {
		let messages = this.state.messages;
		let id = messages.findIndex((m) => m.id == messageId);
		messages.splice(id, 1);
		this.setState({
			messages: messages
		});
	}
	
	render() {
		let workspace = this.state.view === MESVIEW ? <Messages messages={this.state.messages}
		delMessCallback={this.delMessCallback}/>
					: this.state.view === ORDSVIEW ? <DoneOrders orders={this.state.orders} />
					: void 0;
		let navOrdsClass = 'navigation__orders';
		let navMessClass = 'navigation__messages';
		switch (this.state.view) {
		case ORDSVIEW:
			navOrdsClass += ' active';
			break;
		case MESVIEW:
			navMessClass += ' active';
		}
		return (
			<div className='body-wrapper'>
				<nav className='navigation'>
					<ul>
						<li className={navOrdsClass}
								onClick={(e) => this.changeView(ORDSVIEW)}>
							Заказы
						</li>
						
						<li className={navMessClass}
								onClick={(e) => this.changeView(MESVIEW)}>
							Сообщения
						</li>
					</ul>
				</nav>
				<div className='workspace'>
					{workspace}
				</div>
			</div>
		);
	}
}

class DoneOrders extends React.Component {
	constructor(props) {
		super(props);
	}
	
	render() {
		return (
			<div className='done-orders'>
				<div className='summary'>
					Всего: {this.props.orders.length}
				</div>
				<div className='new-order'>
					Add new
				</div>
				<div className='orders'>
				{
					(function(){
						var results = [];
						var orders = this.props.orders;
						var len = orders.length;
						for (let i = 0; i < len; i++) {
																	results.push(
																		<DoneOrder
																			 order={orders[i]}
																			 key={orders[i].id} />
																	);
						}
						return results;
					}).call(this)
				}
			</div>
				</div>
		);
	}
}

class DoneOrder extends React.Component {
	constructor(props) {
		super(props);
	}

	render() {
		return (
			<div className='order'>
				<div className='order__name'>
					{this.props.order.name}
				</div>
				<div className='order__photo'>
					<img src={this.props.order.photo} />
				</div>
				<div className='order__description'>
					{this.props.order.description}
				</div>
			</div>
		);
	}
}

class Messages extends React.Component {
	constructor(props) {
		super(props);
	}
	
	render() {
		return (
			<div className='messages'>
				<div className='summary'> Всего: {this.props.messages.length} </div>
				<table>
					<thead>
						<th>Имя</th>
						<th>Название компании</th>
						<th>Почта</th>
						<th>Телефон</th>
						<th>Вариант заказа</th>
						<th>Комментарий</th>
						<th></th>
					</thead>
					<tbody>
						{
							(function(){
								var i, messages, len;
								messages = this.props.messages;
								len = messages.length;
								var results = [];
								for (i = 0; i < len; i++) {
																	results.push(
																		<Message
																			 message={messages[i]}
																			 key={messages[i].id}
																			 delMessCallback={this.props.delMessCallback} />
																	);
								}
								return results;
							}).call(this)
						}
			</tbody>
				</table>
				</div>
		);
	}
}

class Message extends React.Component {
	constructor(props) {
		super(props);
		this.deleteMessage = this.deleteMessage.bind(this);
	}

	deleteMessage(messageId) {
		var _this = this;
		$.ajax({
			method: 'DELETE',
			url: '/console/delete-message?id='+messageId,
			success: function() {
				_this.props.delMessCallback(messageId);
			},
			error: function(_, text, __) {
				alert(
					"Error occured:\n"
						+ text + "\n"
						+ "Something is wrong with server."
						
				);
			}
		});
	}

	render() {
		let mes = this.props.message;
		return (
			<tr>
				<td>{mes.name}</td>
				<td>{mes.company_name}</td>
				<td>{mes.email}</td>
				<td>{mes.telephone}</td>
				<td>{mes.type_of_order}</td>
				<td>{mes.comment}</td>
				<td className='message__delete'
						onClick={(e) => this.deleteMessage(mes.id)} >
							Нахер!</td>
			</tr>
		);
	}
}
