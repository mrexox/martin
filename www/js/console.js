// -*- mode: rjsx -*-

const MESVIEW = 0;
const ORDSVIEW = 1;
const ORDVIEW = 2;
const ORDEDIT = 3;

class Console extends React.Component {
	constructor(props) {
		super(props);
		this.requestDoneOrders = this.requestDoneOrders.bind(this);
		this.requestMessages = this.requestMessages.bind(this);
		this.changeView = this.changeView.bind(this);		
		this.delMessCallback = this.delMessCallback.bind(this);
		this.viewOrder = this.viewOrder.bind(this);
		this.handleUpdateOrder = this.handleUpdateOrder.bind(this);
		this.handleDeleteOrder = this.handleDeleteOrder.bind(this);
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

	viewOrder(order) {
		this.setState({
			currentOrder: order
		});
		this.changeView(ORDVIEW);
	}
	
	delMessCallback(messageId) {
		let messages = this.state.messages;
		let id = messages.findIndex((m) => m.id == messageId);
		messages.splice(id, 1);
		this.setState({ messages: messages });
	}

	handleUpdateOrder(id, updatedOrder) {
		let orders = this.state.orders;
		let order = $.grep(orders, (or) => {return or.id == id;})[0];
		let index = orders.indexOf(order);
		order.name = updatedOrder.name;
		order.description = updatedOrder.description;
		order.response = updatedOrder.response;
		order.ian_comment = updatedOrder.ian_comment;
		order.valyay_comment = updatedOrder.valyay_comment;
		order.site_href = updatedOrder.site_href;
		orders.splice(index, 1, order);
		console.log(order.photo);
		this.setState({ orders: orders,
										currentOrder: order
									});
		// photo too
	}

	handleDeleteOrder(id) {
		var orders = this.state.orders;
		let order = $.grep(orders, (or) => {return or.id == id;})[0];
		let index = orders.indexOf(order);
		orders.splice(index, 1);
		this.setState({ orders: orders });
	}
	
	render() {
		let view = this.state.view;
		let workspace;
		if( view === MESVIEW ) {
			workspace =
				<Messages
			messages={this.state.messages}
			delMessCallback={this.delMessCallback}/>;
		} else if ( view === ORDSVIEW ) {
			workspace =
				<DoneOrders
			viewOrder={this.viewOrder}
			orders={this.state.orders} />;
		} else if ( view === ORDVIEW ) {
			workspace =
				<DoneOrderFull
			order={this.state.currentOrder}
			handleDeleteOrder={this.handleDeleteOrder}
			back={() => this.changeView(ORDSVIEW)}
			edit={() => this.changeView(ORDEDIT)} />;
		} else if ( view === ORDEDIT) {
			workspace =
				<DoneOrderFullEdit
			order={this.state.currentOrder}
			handleUpdateOrder={this.handleUpdateOrder}
			back={() => this.changeView(ORDVIEW)}/>;
		} else {
			workspace = void 0;
		}
		
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
					Добавить
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
																			 view={(e) => this.props.viewOrder(orders[i])}
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
			<div className='order'
					 onClick={(e) => this.props.view()} >
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

class DoneOrderFull extends React.Component {
	constructor(props) {
		super(props);
		this.deleteOrder = this.deleteOrder.bind(this);
	}

	deleteOrder() {
		let _this = this;
		$.ajax({
			method: 'DELETE',
			url: '/console/done-order?order-id='+this.props.order.id,
			success: function(data) {
				_this.props.handleDeleteOrder(_this.props.order.id);
				_this.props.back();
			},
			error: function(a, b, c) {
				alert('ERROR '+a.responseText+b+c); 
			}
		});
	}

	
	render() {
		let order = this.props.order;
		return (
			<div>
				<div className='button'
						 onClick={(e) => this.props.back()}>
					Назад
				</div>
				<div className='button'
						 onClick={(e) => this.props.edit()}>
					Редактировать
				</div>
				<div className='button'
						 onClick={this.deleteOrder}>
					Удалить
				</div>
				<div className='button inactive'>
					Посмотреть на сайте
				</div>
				<div className='full-order'>
					<div className='full-order__title'>
						{order.name}
					</div>
					<img className='full-order__image' src={order.photo} />
					<div className='full-order__description'>
						{order.description}
					</div>
					<div className='full-order__comment'>
						<div className='full-order__comment1'>
							Иан:<br /><br />
							{order.ian_comment}
						</div>
						<div className='full-order__comment2'>
							Валяй:<br /><br />
							{order.valyay_comment}
						</div>
					</div>
					<div className='full-order__response'>
						Заказчик:<br /> <br />
						{order.response}
					</div>
					<div className='full-order__href'>
						Адрес сайта: <a href={order.site_href}>{order.site_href}</a>
					</div>
				</div>
				
			</div>
		);
	}
}

class DoneOrderFullEdit extends React.Component {
	constructor(props) {
		super(props);
		this.save = this.save.bind(this);
	}

	save() {
		var _this = this;
		var saved = {
				name: $('#title').val(),
				description: $('#description').val(),
				site_href: $('#href').val(),
				response: $('#response').val(),
				valyay_comment: $('#valyay_comment').val(),
				ian_comment: $('#ian_comment').val()
		};
		var _data = JSON.stringify(saved);
		jQuery.ajax({
			dataType: 'json',
			contentType: "application/json; charset=utf-8",
			method: 'POST',
			url: '/console/done-order?order-id=' + this.props.order.id,
			data: _data,
			success: function(data){_this.props.handleUpdateOrder(_this.props.order.id, saved);},
			error: function(a, b, c) {alert('ERROR '+a.responseText+b+c);}
		});
		this.props.back();
	}
	
	render() {
		let order = this.props.order;
		return (
			<div>
				<div className='button'
						 onClick={(e) => this.save()}>
					Сохранить
				</div>
				<div className='full-order'>
					<div className='full-order__title'>
						<input id='title' type='text' defaultValue={order.name} />
					</div>
					<img className='full-order__image' src={order.photo} />
					<div className='full-order__description'>
						<textarea id='description' type='text' defaultValue={order.description} />
					</div>
					<div className='full-order__comment'>
						<div className='full-order__comment1'>
							Иан:<br /><br />
							<textarea id='ian_comment' type='text' defaultValue={order.ian_comment} />
						</div>
						<div className='full-order__comment2'>
							Валяй:<br /><br />
							<textarea id='valyay_comment' type='text' defaultValue={order.valyay_comment} />
						</div>
					</div>
					<div className='full-order__response'>
						Заказчик:<br /><br />
						<textarea id='response' type='text' defaultValue={order.response} />
					</div>
					<div className='full-order__href'>
						Адрес сайта: <input id='href' type='text'defaultValue={order.site_href} />
					</div>
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
