import logo from './logo.svg';
import './App.css';

function App() {
  return (
    <div className="App">
      <header className="App-header">
        <img src={logo} className="App-logo" alt="logo" />
        <p>
          Edit <code>src/App.js</code> and save to reload.
        </p>
        <iframe
          src="https://buy.onramper.com/?apiKey=pk_prod_01GQH660AP1Y1P9425ES10MY58"
          height="630px"
          width="420px"
          title="Onramper widget"
          allow="accelerometer; autoplay; camera; gyroscope; payment">
        </iframe>
      </header>
    </div>
  );
}

export default App;
