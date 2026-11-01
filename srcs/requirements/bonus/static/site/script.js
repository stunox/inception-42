const CODES = {
  0: ["☀️", "Ciel dégagé"], 1: ["🌤️", "Plutôt dégagé"], 2: ["⛅", "Partiellement nuageux"], 3: ["☁️", "Couvert"],
  45: ["🌫️", "Brouillard"], 48: ["🌫️", "Brouillard givrant"],
  51: ["🌦️", "Bruine légère"], 53: ["🌦️", "Bruine"], 55: ["🌧️", "Bruine forte"],
  61: ["🌧️", "Pluie légère"], 63: ["🌧️", "Pluie"], 65: ["🌧️", "Pluie forte"],
  71: ["🌨️", "Neige légère"], 73: ["🌨️", "Neige"], 75: ["❄️", "Neige forte"],
  80: ["🌦️", "Averses"], 81: ["🌧️", "Averses fortes"], 82: ["⛈️", "Averses violentes"],
  95: ["⛈️", "Orage"], 96: ["⛈️", "Orage et grêle"], 99: ["⛈️", "Orage violent"]
};
const info = (code) => CODES[code] || ["🌡️", "Conditions inconnues"];

async function load(coords) {
  const [lat, lon] = coords.split(",");
  const url = "https://api.open-meteo.com/v1/forecast?latitude=" + lat + "&longitude=" + lon +
    "&current=temperature_2m,apparent_temperature,relative_humidity_2m,wind_speed_10m,weather_code" +
    "&daily=weather_code,temperature_2m_max,temperature_2m_min,precipitation_sum" +
    "&timezone=auto&forecast_days=5";
  const now = document.getElementById("now");
  const days = document.getElementById("days");
  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error(res.status);
    const d = await res.json();
    const [icon, text] = info(d.current.weather_code);
    now.innerHTML = '<div class="temp">' + icon + " " + Math.round(d.current.temperature_2m) + "°C</div>" +
      "<div>" + text + " · ressenti " + Math.round(d.current.apparent_temperature) + "°C</div>" +
      "<div>Humidité " + d.current.relative_humidity_2m + " % · vent " + Math.round(d.current.wind_speed_10m) + " km/h</div>";
    days.innerHTML = d.daily.time.map((t, i) => {
      const [ic, label] = info(d.daily.weather_code[i]);
      const name = new Date(t).toLocaleDateString("fr-FR", { weekday: "short", day: "numeric" });
      return '<div class="day"><strong>' + name + '</strong><div class="icon" title="' + label + '">' + ic + "</div>" +
        Math.round(d.daily.temperature_2m_max[i]) + "° / " + Math.round(d.daily.temperature_2m_min[i]) + "°<br>" +
        d.daily.precipitation_sum[i] + " mm</div>";
    }).join("");
  } catch (e) {
    now.textContent = "Impossible de récupérer la météo (connexion internet requise).";
    days.textContent = "";
  }
}

const select = document.getElementById("city");
select.addEventListener("change", () => load(select.value));
load(select.value);